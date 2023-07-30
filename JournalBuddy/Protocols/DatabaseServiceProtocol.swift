//
//  DatabaseServiceProtocol.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

protocol DatabaseServiceProtocol {
    func fetchEntries<T: Entry>(_ entryType: EntryType) async throws -> [T]
    @discardableResult func saveEntry<T: Entry>(_ entry: T) async throws -> T
    func updateEntry<T: Entry>(_ entry: T) async throws

    func fetchTextEntries() async throws -> [TextEntry]
    func saveTextEntry(_ textEntry: TextEntry) async throws -> TextEntry
    func updateTextEntry(_ textEntry: TextEntry) async throws
}
