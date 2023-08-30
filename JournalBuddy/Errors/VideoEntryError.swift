//
//  VideoEntryError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/28/23.
//

import Foundation

enum VideoEntryError: LocalizedError {
    case recordingSetupFailed, cameraSwitchingFailed, noFrontCameraFound, noBackCameraFound, noMicrophoneFound, videoSelectionFailed
    
    var errorDescription: String? {
        switch self {
        case .recordingSetupFailed:
            return "We were unable to configure your device for video recording. Please contact support."
        case .cameraSwitchingFailed:
            return "Camera switch failed, please restart Journal Buddy and try again."
        case .noFrontCameraFound:
            return "We failed to locate your device's front camera. Please restart the app and try again."
        case .noBackCameraFound:
            return "We failed to locate your device's back camera. Please restart the app and try again."
        case .noMicrophoneFound:
            return "We failed to locate your device's microphone. Please restart the app and try again."
        case .videoSelectionFailed:
            return "We were unable to locate the video you selected. Please restart the app and try again."
        }
    }
}
