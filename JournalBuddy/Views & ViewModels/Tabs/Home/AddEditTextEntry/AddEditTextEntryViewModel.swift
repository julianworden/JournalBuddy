//
//  AddEditTextEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

@MainActor
final class AddEditTextEntryViewModel: MainViewModel {
    @Published var viewState = AddEditTextEntryViewState.displayingView
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    var textEntryToEdit: TextEntry?
    var entryText = ""

    var entryIsValid: Bool {
        return !entryText.isReallyEmpty
    }

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, textEntryToEdit: TextEntry?) {
        self.databaseService = databaseService
        self.authService = authService
        self.textEntryToEdit = textEntryToEdit
        self.entryText = textEntryToEdit?.text ?? ""
    }

    func saveTextEntry() async {
        do {
            viewState = .savingTextEntry

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
