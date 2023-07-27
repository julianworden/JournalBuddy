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

    var entryText = ""

    var entryIsValid: Bool {
        return !entryText.isReallyEmpty
    }

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol) {
        self.databaseService = databaseService
        self.authService = authService
    }

    func saveTextEntry() async {
        do {
            guard entryIsValid else {
                viewState = .error(FormError.emptyTextEntry.localizedDescription)
                return
            }

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
            viewState = .error(CustomError.unknown(error.localizedDescription).localizedDescription)
        }
    }
}
