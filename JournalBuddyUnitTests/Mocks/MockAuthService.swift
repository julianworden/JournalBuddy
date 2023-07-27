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
    var userIsLoggedIn = false
    var currentUser: User?
    var currentUserUID = "abc123"

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
