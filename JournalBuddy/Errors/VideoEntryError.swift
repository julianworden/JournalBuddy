//
//  VideoEntryError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/28/23.
//

import Foundation

enum VideoEntryError: LocalizedError {
    case recordingSetupFailed, cameraSwitchingFailed, noFrontCameraFound, noBackCameraFound, noMicrophoneFound, videoSelectionFailed,
    moreThanOneVideoEntryWasSelected, uploadFailed, conversionToDataTypeFailed, failedToFetchDownloadURL
    
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
        case .moreThanOneVideoEntryWasSelected:
            return "We are unable to upload more than one video entry at a time. Please try again and only select one video entry to upload."
        case .uploadFailed:
            return "Something went wrong while we were trying to upload your video entry. Please try again."
        case .conversionToDataTypeFailed:
            return "We failed to encode your video. Please try again."
        case .failedToFetchDownloadURL:
            return "We failed to associate your video entry with a URL. Please contact support."
        }
    }
}
