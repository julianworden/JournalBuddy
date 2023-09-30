//
//  CreateVoiceEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Foundation

enum CreateVoiceEntryViewState: ViewState {
    case displayingView
    case recording
    case audioRecordingHasFinished
    case audioPlayingHasFinished
    case uploadingVoiceEntry
    case uploadedVoiceEntry
    case inadequatePermissions
    case error(message: String)
}
