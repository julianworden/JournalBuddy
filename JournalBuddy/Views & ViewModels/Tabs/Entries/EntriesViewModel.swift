//
//  EntriesViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Foundation

@MainActor
final class EntriesViewModel: MainViewModel {
    @Published var textEntries = [TextEntry]()
    @Published var viewState = EntriesViewState.fetchingEntries

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol) {
        self.databaseService = databaseService
        self.authService = authService
    }

    func fetchTextEntries() async {
        do {
            textEntries = try await databaseService.fetchEntries(.text)
            viewState = .fetchedEntries
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }
}
