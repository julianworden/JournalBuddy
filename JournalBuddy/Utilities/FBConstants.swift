//
//  FBConstants.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import Foundation

enum FBConstants {
    // MARK: - Collections
    static let users = "users"
    static let textEntries = "textEntries"
    static let videoEntries = "videoEntries"
    static let voiceEntries = "voiceEntries"
    static let goals = "goals"

    // MARK: - Fields
    static let id = "id"
    static let uid = "uid"
    static let text = "text"
    static let emailAddress = "emailAddress"
    static let isComplete = "isComplete"
    static let unixDateCreated = "unixDateCreated"
    static let unixDateCompleted = "unixDateCompleted"
    static let numberOfTextEntries = "numberOfTextEntries"
    static let numberOfVideoEntries = "numberOfVideoEntries"
    static let numberOfVoiceEntries = "numberOfVoiceEntries"
    static let numberOfCompleteGoals = "numberOfCompleteGoals"
    
    // MARK: - Batch Sizes
    static let textEntryBatchSize = 12
    static let videoEntryBatchSize = 10
    static let voiceEntryBatchSize = 16
}
