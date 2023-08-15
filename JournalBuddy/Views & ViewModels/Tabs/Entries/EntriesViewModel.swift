//
//  EntriesViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on  7/21/23.
//

import Foundation

@MainActor
final class EntriesViewModel: MainViewModel {
    @Published var customMenuIsShowing = false
    @Published var textEntries = [TextEntry]()
    @Published var viewState = EntriesViewState.fetchingEntries

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User

    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        currentUser: User
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
    }

    func fetchTextEntries() async {
        do {
            textEntries = try await databaseService.fetchEntries(.text, forUID: currentUser.uid)
            viewState = .fetchedEntries
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }
}
