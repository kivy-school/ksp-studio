//
//  InfoPlist.swift
//  PSProjectConfigWasm
//
import Reactivity
import JavaScriptKit
import JavaScriptKitExtensions
import Foundation


@Reactive
final class InfoPlist {
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

extension InfoPlist: ExpressibleByDictionaryLiteral {

    typealias Key = String

    //typealias Value = JSValue

    protocol InfoPlistValue: ConvertibleToJSValue, ConstructibleFromJSValue {

    }

    var sortedArray: [(key: Key, value: Value)] {
        storage.keys.sorted().reduce(into: []) { partialResult, key in
            partialResult.append((key, storage[key]!))
        }
    }
}

extension InfoPlist: ConvertibleToJSValue, ConstructibleFromJSValue {
    var jsValue: JSValue {
        storage.jsValue
    }

    static func construct(from value: JSValue) -> Self? {
        Self.init(storage: .construct(from: value) ?? [:])
    }
}

extension InfoPlist: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}


extension InfoPlist {

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
                 } else if let single = value.string {
                    return .string(.init(storage: single))
                } else {
                    return nil
                }
            }
        }
    }


}

extension InfoPlist.Value: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(entry)
    }
}

extension InfoPlist.Value.Entry: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode(InfoPlist.ArrayValue.self) {
            self = .array(array)
        } else if let dict = try? container.decode(InfoPlist.DictionaryValue.self) {
            self = .dict(dict)
        } else if let bool = try? container.decode(InfoPlist.BoolValue.self) {
            self = .bool(bool)
        } else if let string = try? container.decode(InfoPlist.StringValue.self) {
            self = .string(string)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported Info.plist value")
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


extension InfoPlist {
    @Reactive
    final class StringValue: InfoPlistValue {

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
    final class BoolValue: InfoPlistValue {

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
    final class ArrayValue: InfoPlistValue {

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
    final class DictionaryValue: InfoPlistValue {

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

extension InfoPlist.StringValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

extension InfoPlist.BoolValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

extension InfoPlist.ArrayValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

extension InfoPlist.DictionaryValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}
