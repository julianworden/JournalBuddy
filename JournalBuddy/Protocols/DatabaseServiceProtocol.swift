//
//  DatabaseServiceProtocol.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import FirebaseAuth

protocol DatabaseServiceProtocol {
    func getUser(withUID uid: String) async throws -> User
    func createUser(_ user: User) async throws

    func fetchEntries<T: Entry>(_ entryType: EntryType, forUID uid: String) async throws -> [T]
    @discardableResult func saveEntry<T: Entry>(_ entry: T) async throws -> T
    func updateEntry<T: Entry>(_ entry: T) async throws
    func deleteEntry<T: Entry>(_ entry: T) async throws

    func fetchTextEntries(forUID uid: String) async throws -> [TextEntry]
    func saveTextEntry(_ textEntry: TextEntry) async throws -> TextEntry
    func updateTextEntry(_ textEntry: TextEntry) async throws
}
