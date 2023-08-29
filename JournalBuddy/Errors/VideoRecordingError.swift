//
//  VideoRecordingError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/28/23.
//

import Foundation

enum VideoRecordingError: LocalizedError {
    case recordingSetupFailed, cameraSwitchingFailed
    
    var errorDescription: String? {
        switch self {
        case .recordingSetupFailed:
            return "We were unable to configure your device for video recording. Please contact support."
        case .cameraSwitchingFailed:
            return "Camera switch failed, please restart Journal Buddy and try again."
        }
    }
}
