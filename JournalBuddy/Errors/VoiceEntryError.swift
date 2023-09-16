//
//  VoiceEntryError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Foundation

enum VoiceEntryError: LocalizedError {
    case audioSessionSetupFailed
    case failedToStartRecording
    case failedToStopRecording
    case failedToStartPlaying
    case failedToStopPlaying
    case failedToStartNewRecording
    case insufficientPermissions
    
    var errorDescription: String? {
        switch self {
        case .audioSessionSetupFailed:
            return "We failed to configure audio recording functionality. Please try again."
        case .failedToStartRecording:
            return "We were unable to begin recording your voice entry. Please try again."
        case .failedToStopRecording:
            return "We were unable to stop recording your voice entry. Please try again."
        case .failedToStartPlaying:
            return "We were unable to start playing your voice entry. Please try again."
        case .failedToStopPlaying:
            return "We were unable to stop playing your voice entry. Please try again."
        case .failedToStartNewRecording:
            return "We were unable to start recording a new voice entry. Please go "
        case .insufficientPermissions:
            return "We do not have permission to access the file you selected. Please try again."
        }
    }
}
