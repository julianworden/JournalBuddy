//
//  EntryType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import Foundation

enum EntryType: String, CaseIterable, Codable {
    case text = "Text Entry"
    case video = "Video Entry"
    case voice = "Voice Entry"

    var pluralRawValue: String {
        switch self {
        case .text:
            return "Text Entries"
        case .voice:
            return "Voice Entries"
        case .video:
            return "Video Entries"
        }
    }
    
    /// The name of the `User` field that holds the amount of entries
    /// for an entry type. For example, the user's number of text entries
    /// is stored in `numberOfTextEntries` field.
    var userCounterFieldName: String {
        switch self {
        case .text:
            return FBConstants.numberOfTextEntries
        case .video:
            return FBConstants.numberOfVideoEntries
        case .voice:
            return FBConstants.numberOfVoiceEntries
        }
    }
}
