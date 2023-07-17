//
//  LoginViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import FirebaseAuth

final class LoginViewModel: MainViewModel {
    @Published var loginSuccessful = false

    var emailAddress = ""
    var password = ""

    var error: Error?

    func logIn() {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: emailAddress, password: password)

                await MainActor.run {
                    loginSuccessful = true
                }
            } catch {
                print(error)
            }
        }
    }
}
