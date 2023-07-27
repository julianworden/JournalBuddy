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

    func logIn(withEmail emailAddress: String, andPassword password: String) async throws
    func logOut() throws
    func createAccount(withEmail email: String, andPassword password: String) async throws
}
