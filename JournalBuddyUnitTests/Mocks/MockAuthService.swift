//
//  MockAuthService.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/25/23.
//

import FirebaseAuth
@testable import JournalBuddy

final class MockAuthService: AuthServiceProtocol {
    var errorToThrow: Error?
    /// The  logged in `FirebaseAuth.User`. Not to be used in tests, initializing a FirebaseAuth.User without loggin in does not appear
    /// to be possible but removing this from the AuthServiceProtocol would make the AuthService code more complicated.
    var currentFirebaseAuthUser: FirebaseAuth.User?
    var userIsLoggedIn = false
    let currentUserUID = User.example.uid
    let currentUserEmailAddress = User.example.emailAddress

    init(errorToThrow: Error?) {
        self.errorToThrow = errorToThrow
    }

    func logIn(withEmail emailAddress: String, andPassword password: String) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    func logOut() throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    func createAccount(withEmail email: String, andPassword password: String) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }
}
