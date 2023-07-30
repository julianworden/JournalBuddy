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
    var text: String

    static let example = TextEntry(id: "asdf123", creatorUID: "qwer123", unixDate: 2871047, text: "What a great day!")

    init(id: String, creatorUID: String, unixDate: Double, type: EntryType = .text, text: String) {
        self.id = id
        self.creatorUID = creatorUID
        self.unixDate = unixDate
        self.type = type
        self.text = text
    }
}
