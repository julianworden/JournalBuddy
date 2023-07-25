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

    func signUpButtonTapped() {
        Task {
            do {
                print(emailAddress)
                print(password)
                try await AuthService.shared.createAccount(withEmail: emailAddress, andPassword: password)
                viewState = .accountCreatedSuccessfully
            } catch {
                viewState = .error(error)
            }
        }
    }
}
