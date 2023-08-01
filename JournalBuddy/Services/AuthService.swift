//
//  AuthService.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import FirebaseAuth

final class AuthService: AuthServiceProtocol {
    var currentFirebaseAuthUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    /// The UID for the current `FirebaseAuth.User`. Used to make it easier to test methods that utilize an
    /// object that conforms to `AuthServiceProtocol`, as it does not appear to be possible to initialize
    /// a new `FirebaseAuth.User`.
    var currentUserUID: String {
        return currentFirebaseAuthUser?.uid ?? "Unknown"
    }

    /// The email address for the current `FirebaseAuth.User`. Used to make it easier to test methods that utilize an
    /// object that conforms to `AuthServiceProtocol`, as it does not appear to be possible to initialize
    /// a new `FirebaseAuth.User`.
    var currentUserEmailAddress: String {
        return currentFirebaseAuthUser?.email ?? "Unknown"
    }

    var userIsLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    func logIn(withEmail emailAddress: String, andPassword password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: emailAddress, password: password)
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)

            switch error.code {
            case .invalidEmail:
                throw FBAuthError.invalidEmailAddress
            case .networkError:
                throw FBAuthError.networkError
            case .wrongPassword:
                throw FBAuthError.wrongPasswordOnLogIn
            case .userNotFound:
                // Password and email are valid, but no registered user has this info
                throw FBAuthError.userNotFoundOnLogIn
            default:
                print(error.emojiMessage)
                throw LogicError.unknown(error.localizedDescription)
            }
        }
    }

    func logOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw LogicError.unknown(error.localizedDescription)
        }
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
                throw LogicError.unknown(error.localizedDescription)
            }
        }
    }
}
