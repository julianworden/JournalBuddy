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

    @Published var error: Error?

    func logOut() {
        do {
            try AuthService.shared.logOut()
            userLoggedOut = true
        } catch {
            self.error = error
        }
    }
}

