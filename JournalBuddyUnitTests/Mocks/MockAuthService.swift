//
//  MockAuthService.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/25/23.
//

import FirebaseAuth
@testable import JournalBuddy

final class MockAuthService: AuthServiceProtocol {
    #warning("Make an init for this class so it's easier to inject auth service under different conditions")
    var userIsLoggedIn = false
    var currentUser: User?
    var currentUserUID = "abc123"

    func logOut() throws { }

    func createAccount(withEmail email: String, andPassword password: String) async throws { }
}
