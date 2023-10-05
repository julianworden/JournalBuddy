//
//  User.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/30/23.
//

import Foundation

struct User: Codable, Equatable {
    let uid: String
    let emailAddress: String
    var numberOfTextEntries: Int
    var numberOfVideoEntries: Int
    var numberOfVoiceEntries: Int
    
    init(
        uid: String,
        emailAddress: String,
        numberOfTextEntries: Int = 0,
        numberOfVideoEntries: Int = 0,
        numberOfVoiceEntries: Int = 0
    ) {
        self.uid = uid
        self.emailAddress = emailAddress
        self.numberOfTextEntries = numberOfTextEntries
        self.numberOfVideoEntries = numberOfVideoEntries
        self.numberOfVoiceEntries = numberOfVoiceEntries
    }

    static let example = User(
        uid: "abc123",
        emailAddress: "test@example.com",
        numberOfTextEntries: 24,
        numberOfVideoEntries: 11,
        numberOfVoiceEntries: 17
    )
    
    mutating func incrementNumberOfTextEntries() {
        numberOfTextEntries += 1
    }
    
    mutating func decrementNumberOfTextEntries() {
        numberOfTextEntries -= 1
    }
    
    mutating func incrementNumberOfVideoEntries() {
        numberOfVideoEntries += 1
    }
    
    mutating func decrementNumberOfVideoEntries() {
        numberOfVideoEntries -= 1
    }
    
    mutating func incrementNumberOfVoiceEntries() {
        numberOfVoiceEntries += 1
    }
    
    mutating func decrementNumberOfVoiceEntries() {
        numberOfVoiceEntries -= 1
    }
}
