//
//  NewTextEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

@MainActor
final class NewTextEntryViewModel: MainViewModel {
    var viewState = NewTextEntryViewState.displayingView
    var error: Error?

    var entryText = ""
}
