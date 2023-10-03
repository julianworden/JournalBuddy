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

    func fetchFirstEntriesBatch<T: Entry>(_ entryType: EntryType, forUID uid: String) async throws -> [T] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            switch entryType {
            case .text:
                return Array(TestData.textEntryArray.prefix(12)) as! [T]
            case .video:
                return TestData.videoEntryArray as! [T]
            case .voice:
                return TestData.voiceEntryArray as! [T]
            }
        }
    }
    
    func fetchNextEntriesBatch<T: Entry>(after oldestFetchedEntry: T, forUID uid: String) async throws -> [T] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            switch oldestFetchedEntry.type {
            case .text:
                return TestData.textEntryArray.filter { $0.unixDate < oldestFetchedEntry.unixDate } as! [T]
            case .video:
                return TestData.videoEntryArray as! [T]
            case .voice:
                return TestData.voiceEntryArray as! [T]
            }
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
    
    // MARK: - Goal
    
    func fetchGoals() async throws -> [Goal] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.goalsArray
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
