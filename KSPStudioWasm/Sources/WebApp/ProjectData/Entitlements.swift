//
//  Entitlements.swift
//  PSProjectConfigWasm
//

import Reactivity
import JavaScriptKit
import JavaScriptKitExtensions
import Foundation


@Reactive
final class Entitlements {
    internal init(storage: [Key : Value]) {
        self.storage = storage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.storage = try container.decode([Key: Value].self)
    }

    private var storage: [Key:Value]

    init(dictionaryLiteral elements: (Key, Value)...) {
        storage = .init(uniqueKeysWithValues: elements)
    }

    subscript(key: Key) -> Value? {
        get { storage[key] }
        set {
            if let newValue {
                storage[key] = newValue
            } else {
                storage.removeValue(forKey: key)
            }
        }
    }

    func removeValue(forKey key: String) {
        storage.removeValue(forKey: key)
    }
}

extension Entitlements: ExpressibleByDictionaryLiteral {

    typealias Key = String

    //typealias Value = JSValue

    protocol EntitlementValue: ConvertibleToJSValue, ConstructibleFromJSValue {

    }

    var sortedArray: [(key: Key, value: Value)] {
        storage.keys.sorted().reduce(into: []) { partialResult, key in
            partialResult.append((key, storage[key]!))
        }
    }
}

extension Entitlements: ConvertibleToJSValue, ConstructibleFromJSValue {
    var jsValue: JSValue {
        storage.jsValue
    }

    static func construct(from value: JSValue) -> Self? {
        Self.init(storage: .construct(from: value) ?? [:])
    }
}

extension Entitlements: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}


extension Entitlements {

    @Reactive
    final class Value: ConvertibleToJSValue, ConstructibleFromJSValue, Identifiable {

        let id = UUID().hashValue

        var entry: Entry

        init(entry: Entry) {
            self.entry = entry
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.entry = try container.decode(Entry.self)
        }

        var jsValue: JSValue {
            entry.jsValue
        }

        static func construct(from value: JSValue) -> Self? {
            guard let entry = Entry.construct(from: value) else { return nil }
            return Self.init(entry: entry)
        }

        enum Entry: ConvertibleToJSValue, ConstructibleFromJSValue {
            case string(StringValue)
            case bool(BoolValue)
            case array(ArrayValue)
            case dict(DictionaryValue)

            var jsValue: JSValue {
                switch self {
                    case .string(let value):
                        value.jsValue
                    case .bool(let value):
                        value.jsValue
                    case .array(let array):
                        array.jsValue
                    case .dict(let dictionary):
                        dictionary.jsValue
                }
            }

            init(object: JSObject) {
                self = .dict(.construct(from: object.jsValue) ?? DictionaryValue(storage: [:]))
            }

            static func construct(from value: JSValue) -> Self? {
                if let array = value.array {
                    return .array(.init(array: array))
                } else if let _ = value.object {
                    if let dictValue = DictionaryValue.construct(from: value) {
                        return .dict(dictValue)
                    }
                    return nil
                } else if let bool = value.boolean {
                    return .bool(.init(storage: bool))
                } else if let single = value.string {
                    return .string(.init(storage: single))
                } else {
                    return nil
                }
            }
        }
    }


}

extension Entitlements.Value: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(entry)
    }
}

extension Entitlements.Value.Entry: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode(Entitlements.ArrayValue.self) {
            self = .array(array)
        } else if let dict = try? container.decode(Entitlements.DictionaryValue.self) {
            self = .dict(dict)
        } else if let bool = try? container.decode(Entitlements.BoolValue.self) {
            self = .bool(bool)
        } else if let string = try? container.decode(Entitlements.StringValue.self) {
            self = .string(string)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported entitlement value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .dict(let value): try container.encode(value)
        }
    }
}


extension Entitlements {
    @Reactive
    final class StringValue: EntitlementValue {

        var storage: String

        init(storage: String) {
            self.storage = storage
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.storage = try container.decode(String.self)
        }

        var jsValue: JSValue {
            storage.jsValue
        }

        static func construct(from value: JSValue) -> Self? {
            Self.init(storage: value.string ?? "")
        }
    }

    @Reactive
    final class BoolValue: EntitlementValue {

        var storage: Bool

        init(storage: Bool) {
            self.storage = storage
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.storage = try container.decode(Bool.self)
        }

        var jsValue: JSValue {
            storage.jsValue
        }

        static func construct(from value: JSValue) -> Self? {
            Self.init(storage: value.boolean ?? false)
        }
    }

    @Reactive
    final class ArrayValue: EntitlementValue {

        var storage: [Value]

        init(storage: [Value]) {
            self.storage = storage
        }

        init(array: JSArray) {
            storage = array.compactMap(Value.construct)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.storage = try container.decode([Value].self)
        }

        var jsValue: JSValue {
            storage.jsValue
        }

        static func construct(from value: JSValue) -> Self? {

            return Self.init(storage: .construct(from: value) ?? [])
            //Self.init(storage: value.array.map({[InfoPlist.InfoPlistValue].con}) ?? [])
        }
    }

    @Reactive
    final class DictionaryValue: EntitlementValue {

        var storage: [String:Value]

        init(storage: [String:Value]) {
            self.storage = storage
        }

        init(dict: JSObject) {
            storage = .construct(from: dict.jsValue) ?? [:]
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.storage = try container.decode([String: Value].self)
        }

        var jsValue: JSValue {
            storage.jsValue
        }

        static func construct(from value: JSValue) -> Self? {

            return Self.init(storage: .construct(from: value) ?? [:])
            //Self.init(storage: value.array.map({[InfoPlist.InfoPlistValue].con}) ?? [])
        }
    }
}

extension Entitlements.StringValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

extension Entitlements.BoolValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

extension Entitlements.ArrayValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

extension Entitlements.DictionaryValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}
