//
//  Goal.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/10/23.
//

import Foundation

struct Goal: Codable, Hashable {
    let id: String
    let name: String

    static let example = Goal(id: "asdf123", name: "Get a job.")
}
