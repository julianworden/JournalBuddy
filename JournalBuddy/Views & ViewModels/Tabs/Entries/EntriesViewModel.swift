//
//  EntriesViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

final class EntriesViewModel: MainViewModel {
    var viewState = EntriesViewState.displayingView
    var error: Error?
}
