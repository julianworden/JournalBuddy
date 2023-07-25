//
//  HomeViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import Foundation

@MainActor
final class HomeViewModel: MainViewModel {
    @Published var userLoggedOut = false
    @Published var viewState = HomeViewState.displayingView

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol) {
        self.databaseService = databaseService
        self.authService = authService
    }

    func logOut() {
        do {
            try authService.logOut()
            userLoggedOut = true
        } catch {
            viewState = .error(error)
        }
    }
}

