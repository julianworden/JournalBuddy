//
//  AuthService.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import FirebaseAuth

final class AuthService: AuthServiceProtocol {
    var userIsLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    var currentUserUID: String {
        guard let currentUser else { return "" }

        return currentUser.uid
    }

    func logOut() throws {
        try Auth.auth().signOut()
    }

    func createAccount(withEmail email: String, andPassword password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)

            switch error.code {
            case .invalidEmail, .missingEmail:
                throw FBAuthError.invalidEmailAddress
            case .emailAlreadyInUse:
                throw FBAuthError.emailAlreadyInUseOnSignUp
            case .networkError:
                throw FBAuthError.networkError
            case .weakPassword:
                throw FBAuthError.invalidPasswordOnSignUp
            default:
                throw error
            }
        }
    }
}
