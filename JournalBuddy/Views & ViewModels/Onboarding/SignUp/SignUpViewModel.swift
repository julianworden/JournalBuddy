//
//  SignUpViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import FirebaseAuth

@MainActor
final class SignUpViewModel: MainViewModel {
    @Published var viewState = SignUpViewState.displayingView

    var emailAddress = ""
    var confirmedEmailAddress = ""
    var password = ""
    var confirmedPassword = ""

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol) {
        self.databaseService = databaseService
        self.authService = authService
    }

    var emailAddressesMatch: Bool {
        return emailAddress == confirmedEmailAddress
    }

    var passwordsMatch: Bool {
        return password == confirmedPassword
    }

    func signUpButtonTapped() {
        viewState = .creatingAccount

        guard formIsValid() else { return }

        Task {
            do {
                try await authService.createAccount(withEmail: emailAddress, andPassword: password)
                viewState = .accountCreatedSuccessfully
            } catch {
                viewState = .error(error)
            }
        }
    }

    func formIsValid() -> Bool {
        guard emailAddressesMatch else {
            viewState = .error(CustomError.emailAddressesDoNotMatchOnSignUp)
            return false
        }

        guard passwordsMatch else {
            viewState = .error(CustomError.passwordsDoNotMatchOnSignUp)
            return false
        }

        return true
    }
}
