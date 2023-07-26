//
//  NewTextEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

@MainActor
final class NewTextEntryViewModel: MainViewModel {
    @Published var viewState = NewTextEntryViewState.displayingView
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var error: Error?
    var entryText = ""

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol) {
        self.databaseService = databaseService
        self.authService = authService
    }

    func saveTextEntry() {
        Task {
            do {
                let textEntry = TextEntry(
                    id: "",
                    creatorUID: authService.currentUserUID,
                    unixDate: Date.now.timeIntervalSince1970,
                    text: entryText
                )

                try await databaseService.saveEntry(textEntry)
                viewState = .textEntrySaved
            } catch {
                print(error.emojiMessage)
                self.error = CustomError.unknown(error.localizedDescription)
            }
        }
    }
}
