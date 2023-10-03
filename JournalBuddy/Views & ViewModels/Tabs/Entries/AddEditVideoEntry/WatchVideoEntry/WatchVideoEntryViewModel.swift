//
//  WatchVideoEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/24/23.
//

import Foundation

@MainActor
final class WatchVideoEntryViewModel: MainViewModel {
    @Published var viewState = WatchVideoEntryViewState.displayingView
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let videoEntry: VideoEntry
    
    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        videoEntry: VideoEntry
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.videoEntry = videoEntry
    }
    
    func deleteVideoEntry() async {
        do {
            viewState = .deletingVideoEntry
            try await databaseService.deleteEntry(videoEntry)
            postDeletedVideoEntryNotification()
            viewState = .deletedVideoEntry
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func postDeletedVideoEntryNotification() {
        NotificationCenter.default.post(
            name: .videoEntryWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedVideoEntry: videoEntry]
        )
    }
}
