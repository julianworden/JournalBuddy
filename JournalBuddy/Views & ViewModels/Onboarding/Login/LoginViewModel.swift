//
//  LoginViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import Foundation

@MainActor
final class LoginViewModel: MainViewModel {
    @Published var viewState = LoginViewState.displayingView

    var emailAddress = ""
    var password = ""

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol) {
        self.databaseService = databaseService
        self.authService = authService
    }

    func logIn() async {
        do {
            viewState = .loggingIn
            try await authService.logIn(withEmail: emailAddress, andPassword: password)

            // Doing this instead of using AuthDataResult because FirebaseAuth.User isn't testable
            let currentUser = try await databaseService.getUser(withUID: authService.currentUserUID)
            viewState = .loggedIn(currentUser)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}
