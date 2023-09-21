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

    // MARK: - User

    func getUser(withUID uid: String) async throws -> User {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return User.example
        }
    }

    func createUser(_ user: JournalBuddy.User) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    // MARK: - Generic Entry CRUD

    func fetchEntries<T: Entry>(_ entryType: EntryType, forUID uid: String) async throws -> [T] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.textEntryArray as! [T]
        }
    }

    func saveEntry<T: Entry>(_ entry: T, at url: URL?) async throws -> T {
        if let errorToThrow {
            throw errorToThrow
        } else {
            switch entry.type {
            case .text:
                return TextEntry.example as! T
            case .video:
                return VideoEntry.example as! T
            case .voice:
                return VoiceEntry.example as! T
            }
        }
    }

    func updateEntry<T: Entry>(_ entry: T) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    func deleteEntry<T: Entry>(_ entry: T) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    // MARK: - TextEntry

    func fetchTextEntries(forUID uid: String) async throws -> [TextEntry] {
        return []
    }
    
    // MARK: - Goal
    
    func fetchGoals() async throws -> [Goal] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return []
        }
    }
    
    func saveNewGoal(_ newGoal: Goal) async throws -> Goal {
        if let errorToThrow {
            throw errorToThrow
        }
        
        return newGoal
    }
    
    func completeGoal(_ completedGoal: JournalBuddy.Goal) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }
    
    func updateGoal(_ updatedGoal: Goal) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }
    
    func deleteGoal(_ goalToDelete: JournalBuddy.Goal) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }
    
    
}
