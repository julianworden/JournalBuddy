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
        Goal(id: "asdf123", name: "Get a job that pays really really really well."),
        Goal(id: "qwer123", name: "Pay off all the student loans because oh boy are they a lot of money."),
        Goal(id: "zxcv123", name: "Start business and make a lot lot lot lot of money.")
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

