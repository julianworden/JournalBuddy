//
//  UploadVideoEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

enum UploadVideoEntryViewState: ViewState {
    case displayingView, videoEntryWasCreated, error(message: String)
}
