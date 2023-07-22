//
//  MockDatabaseService.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

@testable import JournalBuddy
import Foundation

final class MockDatabaseService: DatabaseServiceProtocol {
    func saveEntry<T: Entry>(_ entry: T) async throws -> T {
        switch entry.type {
        case .text:
            return try await saveTextEntry(entry as! TextEntry) as! T
        default:
            throw TestError.functionalityNotImplemented(message: "Only TextEntry has been implemented.")
        }
    }

    func saveTextEntry(_ textEntry: JournalBuddy.TextEntry) async throws -> JournalBuddy.TextEntry {
        var textEntryWithID = textEntry
        textEntryWithID.id = UUID().uuidString
        return textEntryWithID
    }
}
