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
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696282763,
            text: "What a great day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696196363,
            text: "What a bad day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696109963,
            text: "What a terrible day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696023563,
            text: "What an amazing day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695937163,
            text: "What a fantastic day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695850763,
            text: "What a great day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695764363,
            text: "What a bad day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695677963,
            text: "What a terrible day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695591563,
            text: "What an amazing day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695505163,
            text: "What a fantastic day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695418763,
            text: "What an amazing day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695332363,
            text: "What a fantastic day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695073521,
            text: "What a great day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694987121,
            text: "What a bad day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694900721,
            text: "What a terrible day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694814321,
            text: "What an amazing day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694727921,
            text: "What a fantastic day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694641521,
            text: "What a great day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694555121,
            text: "What a bad day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694468721,
            text: "What a terrible day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694382321,
            text: "What an amazing day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694295921,
            text: "What a fantastic day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694209521,
            text: "What an amazing day!"
        ),
        TextEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694123121,
            text: "What a fantastic day!"
        )
    ]
    
    static let videoEntryArray = [
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696282763,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696196363,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696109963,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696023563,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695937163,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695850763,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695764363,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695677963,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695591563,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695505163,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        ),
        VideoEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695418763,
            downloadURL: UUID().uuidString,
            thumbnailDownloadURL: UUID().uuidString
        )
    ]
    
    static let voiceEntryArray = [
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696282763,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696196363,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696109963,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1696023563,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695937163,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695850763,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695764363,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695677963,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695591563,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695505163,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695418763,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695332363,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1695073521,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694987121,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694900721,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694814321,
            downloadURL: UUID().uuidString
        ),
        VoiceEntry(
            id: UUID().uuidString,
            creatorUID: UUID().uuidString,
            unixDate: 1694727921,
            downloadURL: UUID().uuidString
        )
    ]
    
    static let goalsArray = [
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Pay off loan", isComplete: true),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Go back to school", isComplete: true),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Make $1,000,000", isComplete: false),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Take a vacation", isComplete: false),
        Goal(id: UUID().uuidString, creatorUID: UUID().uuidString, name: "Get a new job", isComplete: false)
    ]
}
