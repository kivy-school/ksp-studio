//
//  BackendKey.swift
//  PSProjectConfigWasm
//


public enum BackendKey: String, CaseIterable, Sendable {
    case kivylauncher = "kivyschool.kivylauncher"
    case kivy3launcher = "kivyschool.kivy3launcher"
    case pyswiftui = "pyswiftui"

    public var label: String {
        switch self {
        case .kivylauncher:  "Kivy Launcher"
        case .kivy3launcher: "Kivy 3 Launcher"
        case .pyswiftui:     "PySwiftUI"
        }
    }

    public var category: Category {
        switch self {
        case .kivylauncher, .kivy3launcher: .kivy
        case .pyswiftui: .swift
        }
    }

    public enum Category: String, Sendable {
        case kivy = "Kivy"
        case swift = "Swift"
    }
}

import JavaScriptKit

extension BackendKey: ConvertibleToJSValue, ConstructibleFromJSValue {
    
    public var jsValue: JSValue { rawValue.jsValue }
    
    public static func construct(from value: JSValue) -> BackendKey? {
        guard let string = value.string else { return nil }
        return .init(rawValue: string)
    }
}
