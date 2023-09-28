//
//  UploadVideoEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

enum UploadVideoEntryViewState: ViewState {
    case displayingView
    case videoEntryIsSavingToDevice
    case videoEntryWasSavedToDevice
    case videoEntryIsUploading
    case videoEntryWasUploaded
    case error(message: String)
}
