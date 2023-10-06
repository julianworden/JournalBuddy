//
//  Goal.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/10/23.
//

import Foundation

struct Goal: Codable, Hashable {
    var id: String
    let creatorUID: String
    let unixDateCreated: Double
    var unixDateCompleted: Double?
    var name: String
    var isComplete: Bool
    
    init(
        id: String,
        creatorUID: String,
        unixDateCreated: Double = Date.now.timeIntervalSince1970,
        unixDateCompleted: Double? = nil,
        name: String,
        isComplete: Bool = false
    ) {
        self.id = id
        self.creatorUID = creatorUID
        self.unixDateCreated = unixDateCreated
        self.unixDateCompleted = unixDateCompleted
        self.name = name
        self.isComplete = isComplete
    }

    static let example = Goal(
        id: "asdf123",
        creatorUID: UUID().uuidString,
        name: "Get a job."
    )
    
    mutating func complete() {
        unixDateCompleted = Date.now.timeIntervalSince1970
        isComplete = true
    }
}
