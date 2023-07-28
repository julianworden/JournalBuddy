//
//  MockDatabaseService.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

@testable import JournalBuddy
import Foundation

final class MockDatabaseService: DatabaseServiceProtocol {
    var errorToThrow: Error?

    init(errorToThrow: Error?) {
        self.errorToThrow = errorToThrow
    }

    func fetchEntries<T: Entry>(_ entryType: EntryType) async throws -> [T] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.textEntryArray as! [T]
        }
    }

    func saveEntry<T: Entry>(_ entry: T) async throws -> T {
        do {
            switch entry.type {
            case .text:
                return try await saveTextEntry(entry as! TextEntry) as! T
            default:
                fatalError("Entry type not implemented.")
            }
        } catch {
            throw error
        }
    }

    func fetchTextEntries() async throws -> [TextEntry] {
        return []
    }

    func saveTextEntry(_ textEntry: JournalBuddy.TextEntry) async throws -> JournalBuddy.TextEntry {
        if let errorToThrow {
            throw errorToThrow
        } else {
            var textEntryWithID = textEntry
            textEntryWithID.id = UUID().uuidString
            return textEntryWithID
        }
    }
}
