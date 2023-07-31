//
//  AddEditTextEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import UIKit

@MainActor
final class AddEditTextEntryViewModel: MainViewModel {
    var textEntryToEdit: TextEntry?
    @Published var entryText = ""

    @Published var viewState = AddEditTextEntryViewState.displayingView
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    var entryTextViewDefaultText: String {
        if let textEntryToEdit {
            return textEntryToEdit.text
        } else {
            return "Tap anywhere to begin writing..."
        }
    }

    var entryTextViewDefaultTextColor: UIColor {
        if textEntryToEdit == nil {
            return .secondaryLabel
        } else {
            return .label
        }
    }

    var entryIsEmpty: Bool {
        return entryText.isReallyEmpty
    }

    var entryHasBeenEdited: Bool {
        guard let textEntryToEdit else { return false }

        return entryText != textEntryToEdit.text
    }

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, textEntryToEdit: TextEntry?) {
        self.databaseService = databaseService
        self.authService = authService
        self.textEntryToEdit = textEntryToEdit
        self.entryText = textEntryToEdit?.text ?? ""
    }

    func saveTextEntry() async {
        if let textEntryToEdit {
            await updateExistingTextEntry(textEntryToEdit)
        } else {
            await saveNewTextEntry()
        }
    }

    func saveNewTextEntry() async {
        do {
            viewState = .savingTextEntry

            guard !entryIsEmpty else {
                viewState = .error(FormError.textEntryIsEmpty.localizedDescription)
                return
            }

            #warning("Nil Coaelescing shouldn't happen")
            let textEntry = TextEntry(
                id: "",
                creatorUID: authService.currentUserUID ?? "",
                unixDate: Date.now.timeIntervalSince1970,
                text: entryText
            )

            try await databaseService.saveEntry(textEntry)
            viewState = .textEntrySaved
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }

    func updateExistingTextEntry(_ existingTextEntry: TextEntry) async {
        do {
            viewState = .textEntryUpdating

            guard entryHasBeenEdited else {
                viewState = .error(FormError.textEntryHasNotBeenUpdated.localizedDescription)
                return
            }

            guard !entryIsEmpty else {
                viewState = .error(FormError.textEntryIsEmpty.localizedDescription)
                return
            }

            var updatedTextEntry = existingTextEntry
            updatedTextEntry.text = entryText

            try await databaseService.updateEntry(updatedTextEntry)
            viewState = .textEntryUpdated
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }
}
