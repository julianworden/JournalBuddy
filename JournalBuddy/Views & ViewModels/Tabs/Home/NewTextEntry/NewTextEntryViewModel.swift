//
//  NewTextEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

@MainActor
final class NewTextEntryViewModel: MainViewModel {
    let databaseService: DatabaseServiceProtocol
    var viewState = NewTextEntryViewState.displayingView
    var error: Error?
    var entryText = ""

    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
    }

    func saveTextEntry() {
        Task {
            do {
                let textEntry = TextEntry(
                    id: "",
                    creatorUID: AuthService.shared.currentUserUID,
                    unixDate: Date.now.timeIntervalSince1970,
                    text: entryText
                )

                try await databaseService.saveEntry(textEntry)
            } catch {
                self.error = error
            }
        }
    }
}
