//
//  EntriesViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on  7/21/23.
//

import Foundation

@MainActor
final class EntriesViewModel: MainViewModel {
    enum SelectedEntryType {
        case text, video, voice
    }
    
    @Published var customMenuIsShowing = false
    @Published var textEntries = [TextEntry]()
    @Published var videoEntries = [VideoEntry]()
    @Published var viewState = EntriesViewState.fetchingTextEntries
    var selectedEntryType = SelectedEntryType.text

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
            viewState = .fetchedTextEntries
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func fetchVideoEntries() async {
        do {
            viewState = .fetchingVideoEntries
            videoEntries = try await databaseService.fetchEntries(.video, forUID: currentUser.uid)
            viewState = .fetchedVideoEntries
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
}
