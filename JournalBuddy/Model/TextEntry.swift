//
//  TextEntry.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/12/23.
//

import Foundation

struct TextEntry: Entry {
    var id: String
    let creatorUID: String
    let unixDateCreated: Double
    let type: EntryType
    var text: String

    static let example = TextEntry(
        id: "asdf123",
        creatorUID: "qwer123",
        text: "What a great day!"
    )

    init(
        id: String,
        creatorUID: String,
        unixDateCreated: Double = Date.now.timeIntervalSince1970,
        type: EntryType = .text,
        text: String
    ) {
        self.id = id
        self.creatorUID = creatorUID
        self.unixDateCreated = unixDateCreated
        self.type = type
        self.text = text
    }
}
