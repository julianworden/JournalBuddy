//
//  TextEntry.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/12/23.
//

struct TextEntry: Entry, Hashable {
    var id: String
    let creatorUID: String
    let unixDate: Double
    let type: EntryType
    let text: String

    init(id: String, creatorUID: String, unixDate: Double, type: EntryType = .text, text: String) {
        self.id = id
        self.creatorUID = creatorUID
        self.unixDate = unixDate
        self.type = type
        self.text = text
    }
}
