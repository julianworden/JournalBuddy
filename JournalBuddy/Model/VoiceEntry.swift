//
//  VoiceEntry.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/16/23.
//

import Foundation

struct VoiceEntry: Entry {
    var id: String
    let creatorUID: String
    let unixDate: Double
    var downloadURL: String
    let type: EntryType
    
    static let example = VoiceEntry(
        id: UUID().uuidString,
        creatorUID: UUID().uuidString,
        unixDate: Date.now.timeIntervalSince1970,
        downloadURL: UUID().uuidString
    )
    
    init(
        id: String,
        creatorUID: String,
        unixDate: Double,
        downloadURL: String,
        type: EntryType = .voice
    ) {
        self.id = id
        self.creatorUID = creatorUID
        self.unixDate = unixDate
        self.downloadURL = downloadURL
        self.type = type
    }
}
