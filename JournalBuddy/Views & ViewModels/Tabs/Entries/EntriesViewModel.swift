//
//  EntriesViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on  7/21/23.
//

import Combine
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
    /// Establishes whether or not the view model has ever queried Firestore for text entries. This property is used
    /// in the view to determine the behavior of the view when navigating between entry types.
    var textEntriesQueryPerformed = false
    /// Establishes whether or not the view model has ever queried Firestore for video entries. This property is used
    /// in the view to determine the behavior of the view when navigating between entry types.
    var videoEntriesQueryPerformed = false

    var cancellables = Set<AnyCancellable>()
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

    /// Fetches all of the logged in user's text entries.
    /// - Parameter performEntryQuery: Makes it possible to test case where no text entries are found. Defaults to true
    /// because this property should never be used in production.
    func fetchTextEntries(performEntryQuery: Bool = true) async {
        do {
            viewState = .fetchingTextEntries
            if performEntryQuery {
                textEntries = try await databaseService.fetchEntries(.text, forUID: currentUser.uid)
            }

            if textEntries.isEmpty {
                viewState = .noTextEntriesFound
            } else {
                viewState = .fetchedTextEntries
            }
            
            textEntriesQueryPerformed = true
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Fetches all of the logged in user's video entries.
    /// - Parameter performEntryQuery: Makes it possible to test case where no video entries are found. Defaults to true
    /// because this property should never be used in production.
    func fetchVideoEntries(performEntryQuery: Bool = true) async {
        do {
            viewState = .fetchingVideoEntries
            if performEntryQuery {
                videoEntries = try await databaseService.fetchEntries(.video, forUID: currentUser.uid)
            }
            
            if videoEntries.isEmpty {
                viewState = .noVideoEntriesFound
            } else {
                viewState = .fetchedVideoEntries
            }
            
            videoEntriesQueryPerformed = true
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func subscribeToPublishers() {
        NotificationCenter.default.publisher(for: .videoEntryWasDeleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let deletedVideoEntry = notification.userInfo?[NotificationConstants.deletedVideoEntry] as? VideoEntry else {
                    print("❌ videoEntryWasDeleted notification posted without entry info.")
                    return
                }
                
                guard let deletedVideoEntryIndex = self.videoEntries.firstIndex(of: deletedVideoEntry) else {
                    print("❌ deleted video entry not found in videoEntries array.")
                    return
                }
                
                self.videoEntries.remove(at: deletedVideoEntryIndex)
                
                if self.videoEntries.isEmpty {
                    self.viewState = .noVideoEntriesFound
                }
            }
            .store(in: &cancellables)
    }
}
