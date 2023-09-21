//
//  TestData.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

import Foundation
@testable import JournalBuddy

enum TestData {
    static let textEntryArray = [
        TextEntry(id: "0", creatorUID: "asdf1234", unixDate: 12345678, text: "What a great day!"),
        TextEntry(id: "1", creatorUID: "qwer1234", unixDate: 44562363, text: "What a bad day!"),
        TextEntry(id: "2", creatorUID: "zxcv1234", unixDate: 75684739, text: "What a terrible day!"),
        TextEntry(id: "3", creatorUID: "hjkl1234", unixDate: 10389475, text: "What an amazing day!"),
        TextEntry(id: "4", creatorUID: "uiop1234", unixDate: 30927456, text: "What a fantastic day!")
    ]
    
    static let goalsArray = [
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Pay off loan", isComplete: true),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Go back to school", isComplete: true),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Make $1,000,000", isComplete: false),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Take a vacation", isComplete: false),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Get a new job", isComplete: false)
    ]
}
