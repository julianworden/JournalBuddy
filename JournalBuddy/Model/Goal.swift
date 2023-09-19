//
//  Goal.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/10/23.
//

import Foundation

struct Goal: Codable, Hashable {
    let id: String
    var name: String
    let creatorUID: String

    static let example = Goal(
        id: "asdf123",
        name: "Get a job.",
        creatorUID: UUID().uuidString
    )
}
