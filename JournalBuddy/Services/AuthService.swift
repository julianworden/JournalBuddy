//
//  AuthService.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import FirebaseAuth

final class AuthService {
    static let shared = AuthService()

    private init() { }

    var userIsLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    func logOut() throws {
        try Auth.auth().signOut()
    }
}
