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
}
