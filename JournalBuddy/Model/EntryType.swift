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
}
