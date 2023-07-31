//
//  User.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/30/23.
//

import Foundation

struct User: Codable, Equatable {
    let uid: String
    let emailAddress: String

    static let example = User(uid: "abc123", emailAddress: "test@example.com")
}
