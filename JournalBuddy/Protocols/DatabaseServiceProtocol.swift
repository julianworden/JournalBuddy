//
//  DatabaseServiceProtocol.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import FirebaseAuth

#warning("Remove methods that are only called from within DatabaseService from this Protocol and make those methods private in DatabaseService.")

protocol DatabaseServiceProtocol {
    func getUser(withUID uid: String) async throws -> User
    func createUser(_ user: User) async throws

    func fetchEntries<T: Entry>(_ entryType: EntryType, forUID uid: String) async throws -> [T]
    @discardableResult func saveEntry<T: Entry>(_ entry: T, at url: URL?) async throws -> T
    func updateEntry<T: Entry>(_ entry: T) async throws
    func deleteEntry<T: Entry>(_ entry: T) async throws

    func fetchTextEntries(forUID uid: String) async throws -> [TextEntry]
    
    func fetchGoals() async throws -> [Goal]
    func saveNewGoal(_ newGoal: Goal) async throws
    func updateGoal(_ updatedGoal: Goal) async throws
}
