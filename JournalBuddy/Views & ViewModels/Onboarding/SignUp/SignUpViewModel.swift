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

    func signUpButtonTapped() async {
        viewState = .creatingAccount

        guard formIsValid() else { return }

        do {
            try await authService.createAccount(withEmail: emailAddress, andPassword: password)
            viewState = .accountCreatedSuccessfully
        } catch {
            print(error.emojiMessage)
            viewState = .error(error.localizedDescription)
        }
    }

    func formIsValid() -> Bool {
        guard emailAddressesMatch else {
            viewState = .error(FormError.emailAddressesDoNotMatchOnSignUp.localizedDescription)
            return false
        }

        guard passwordsMatch else {
            viewState = .error(FormError.passwordsDoNotMatchOnSignUp.localizedDescription)
            return false
        }

        return true
    }
}
