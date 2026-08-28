//
//  PickableKey.swift
//  PSProjectConfigWasm
//
//  Created by CodeBuilder on 05/03/2026.
//


/// A named key that can be picked from a preset list (e.g. Info.plist keys, entitlements).
public struct PickableKey: Sendable {
    public var category: String
    public var label: String
    public var rawValue: String

    public init(category: String, label: String, rawValue: String) {
        self.category = category
        self.label = label
        self.rawValue = rawValue
    }
}