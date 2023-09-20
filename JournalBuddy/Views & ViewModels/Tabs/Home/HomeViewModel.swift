//
//  HomeViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import Foundation

@MainActor
final class HomeViewModel: MainViewModel {
    @Published var viewState = HomeViewState.displayingView
    @Published var userGoals = [
        Goal(
            id: "asdf123",
            creatorUID: UUID().uuidString,
            name: "Get a raise."
        ),
        Goal(
            id: "qwer123",
            creatorUID: UUID().uuidString,
            name: "Pay off student loans."
            
        ),
        Goal(
            id: "zxcv123",
            creatorUID: UUID().uuidString,
            name: "Rule the world."
        )
    ]

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, currentUser: User) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
    }

    func logOut() {
        do {
            try authService.logOut()
            viewState = .userLoggedOut
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }
}

