//
//  LoginViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import FirebaseAuth

@MainActor
final class LoginViewModel: MainViewModel {
    @Published var viewState = LoginViewState.displayingView
    @Published var loginSuccessful = false

    var emailAddress = ""
    var password = ""

    var error: Error?

    func logIn() {
        Task {
            do {
                viewState = .loggingIn

                try await Auth.auth().signIn(withEmail: emailAddress, password: password)

                loginSuccessful = true
            } catch {
                let error = AuthErrorCode(_nsError: error as NSError)

                handleLogInError(error)
            }
        }
    }

    func handleLogInError(_ error: AuthErrorCode) {
        switch error.code {
        case .invalidEmail:
            viewState = .error(FBAuthError.invalidEmailAddress.localizedDescription)
        case .networkError:
            viewState = .error(FBAuthError.networkError.localizedDescription)
        case .wrongPassword:
            viewState = .error(FBAuthError.wrongPasswordOnLogIn.localizedDescription)
        case .userNotFound:
            // Password and email are valid, but no registered user has this info
            viewState = .error(FBAuthError.userNotFoundOnLogIn.localizedDescription)
        default:
            print(error.emojiMessage)
            viewState = .error(CustomError.unknown(error.localizedDescription).localizedDescription)
        }
    }
}
