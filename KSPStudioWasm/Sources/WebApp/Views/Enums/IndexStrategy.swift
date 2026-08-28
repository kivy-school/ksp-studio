//
//  IndexStrategy.swift
//  PSProjectConfigWasm
//

public enum IndexStrategy: String, CaseIterable, Codable {
    case first_index = "first-index"
    case unsafe_first_match = "unsafe-first-match"
    case unsafe_best_match = "unsafe-best-match"
}
