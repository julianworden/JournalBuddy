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
    let currentUser: User

    var navigationTitle: String {
        if textEntryToEdit != nil {
            return "Edit Text Entry"
        } else {
            return "New Text Entry"
        }
    }

    var navigationBarShouldHideMoreButton: Bool {
        return textEntryToEdit == nil
    }

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

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, currentUser: User, textEntryToEdit: TextEntry?) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
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
            guard !entryIsEmpty else {
                viewState = .error(FormError.textEntryIsEmpty.localizedDescription)
                return
            }

            viewState = .savingTextEntry


            let textEntry = TextEntry(
                id: "",
                creatorUID: currentUser.uid,
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
            guard entryHasBeenEdited else {
                viewState = .error(FormError.textEntryHasNotBeenUpdated.localizedDescription)
                return
            }

            guard !entryIsEmpty else {
                viewState = .error(FormError.textEntryIsEmpty.localizedDescription)
                return
            }

            viewState = .updatingTextEntry

            var updatedTextEntry = existingTextEntry
            updatedTextEntry.text = entryText

            try await databaseService.updateEntry(updatedTextEntry)
            viewState = .updatedTextEntry
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }

    func deleteTextEntry() async {
        guard let textEntryToEdit else {
            viewState = .error(LogicError.deletingNonExistentEntry.localizedDescription)
            return
        }

        do {
            viewState = .deletingTextEntry
            try await databaseService.deleteEntry(textEntryToEdit)
            viewState = .deletedTextEntry
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }
}
