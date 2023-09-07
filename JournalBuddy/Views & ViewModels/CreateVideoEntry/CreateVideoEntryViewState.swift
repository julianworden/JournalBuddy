//
//  CreateVideoEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Foundation

enum CreateVideoEntryViewState: ViewState {
    case displayingView
    case recordingVideo
    case videoEntryWasSelectedOrRecorded(at: URL, videoWasSelectedFromLibrary: Bool)
    case error(message: String)
}
