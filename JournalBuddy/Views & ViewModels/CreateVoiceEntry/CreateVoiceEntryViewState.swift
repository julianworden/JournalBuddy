//
//  CreateVoiceEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Foundation

enum CreateVoiceEntryViewState: ViewState {
    case displayingView
    case audioIsRecording
    case audioRecordingHasFinished
    case audioIsPlaying
    case audioWasPaused
    case audioPlayingHasFinished
    case inadequatePermissions
    case error(message: String)
}
