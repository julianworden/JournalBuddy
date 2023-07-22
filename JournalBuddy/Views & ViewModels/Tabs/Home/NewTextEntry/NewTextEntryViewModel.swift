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

    func saveTextEntry() {
        Task {
            do {
                let textEntry = TextEntry(
                    id: "",
                    creatorUID: AuthService.shared.currentUserUID,
                    unixDate: Date.now.timeIntervalSince1970,
                    text: entryText
                )

                let savedEntry = try await DatabaseService.shared.saveEntry(textEntry)
                print(savedEntry)
            } catch {
                self.error = error
            }
        }
    }
}
