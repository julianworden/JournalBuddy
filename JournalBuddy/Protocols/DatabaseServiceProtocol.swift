//
//  DatabaseServiceProtocol.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

protocol DatabaseServiceProtocol {
    @discardableResult func saveEntry<T: Entry>(_ entry: T) async throws -> T
    func saveTextEntry(_ textEntry: TextEntry) async throws -> TextEntry
}
