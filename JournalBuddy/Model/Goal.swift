//
//  Goal.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/10/23.
//

import Foundation

struct Goal: Codable, Hashable {
    let id: String
    let creatorUID: String
    var name: String
    var isComplete: Bool
    
    init(id: String, creatorUID: String, name: String, isComplete: Bool = false) {
        self.id = id
        self.creatorUID = creatorUID
        self.name = name
        self.isComplete = isComplete
    }

    static let example = Goal(
        id: "asdf123",
        creatorUID: UUID().uuidString,
        name: "Get a job."
    )
}
