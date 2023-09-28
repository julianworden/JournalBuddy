//
//  ListenToVoiceEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/27/23.
//

enum ListenToVoiceEntryViewState: ViewState {
    case fetchingVoiceEntry
    case fetchedVoiceEntry
    case deletingVoiceEntry
    case deletedVoiceEntry
    case audioPlayingHasFinished
    case error(message: String)
}
