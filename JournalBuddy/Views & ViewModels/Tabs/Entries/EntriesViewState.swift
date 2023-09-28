//
//  EntriesViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

enum EntriesViewState: ViewState {
    case displayingView
    case fetchingTextEntries
    case fetchedTextEntries
    case noTextEntriesFound
    case fetchingVideoEntries
    case fetchedVideoEntries
    case noVideoEntriesFound
    case fetchingVoiceEntries
    case fetchedVoiceEntries
    case noVoiceEntriesFound
    case error(message: String)
}
