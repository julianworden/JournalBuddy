//
//  UploadVideoEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

enum UploadVideoEntryViewState: ViewState {
    case displayingView, videoEntryIsUploading, videoEntryWasUploaded, error(message: String)
}
