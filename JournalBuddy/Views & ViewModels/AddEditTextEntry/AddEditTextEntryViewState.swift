//
//  AddEditTextEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

enum AddEditTextEntryViewState: ViewState {
    case displayingView, savingTextEntry, textEntrySaved, textEntryUpdating, textEntryUpdated, error(String)
}
