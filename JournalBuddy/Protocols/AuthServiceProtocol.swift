//
//  AuthServiceProtocol.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

import FirebaseAuth

protocol AuthServiceProtocol {
    var userIsLoggedIn: Bool { get }
    var currentUser: FirebaseAuth.User? { get }
    var currentUserUID: String { get }

    func logOut() throws
    func createAccount(withEmail email: String, andPassword password: String) async throws
}
