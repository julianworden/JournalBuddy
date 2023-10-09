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

    func createUser(_ user: User) throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    // MARK: - Generic Entry CRUD

    func fetchFirstEntriesBatch<T: Entry>(_ entryType: EntryType) async throws -> [T] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            switch entryType {
            case .text:
                return Array(TestData.textEntryArray.prefix(FBConstants.textEntryBatchSize)) as! [T]
            case .video:
                return Array(TestData.videoEntryArray.prefix(FBConstants.videoEntryBatchSize)) as! [T]
            case .voice:
                return Array(TestData.voiceEntryArray.prefix(FBConstants.voiceEntryBatchSize)) as! [T]
            }
        }
    }
    
    func fetchNextEntriesBatch<T: Entry>(after oldestFetchedEntry: T) async throws -> [T] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            switch oldestFetchedEntry.type {
            case .text:
                return TestData.textEntryArray.filter { $0.unixDateCreated < oldestFetchedEntry.unixDateCreated } as! [T]
            case .video:
                return TestData.videoEntryArray.filter { $0.unixDateCreated < oldestFetchedEntry.unixDateCreated } as! [T]
            case .voice:
                return TestData.voiceEntryArray.filter { $0.unixDateCreated < oldestFetchedEntry.unixDateCreated } as! [T]
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
    
    func fetchFirstIncompleteGoalBatch() async throws -> [Goal] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.goalsArray
                .filter(where: { !$0.isComplete }, limit: FBConstants.goalBatchSize)
                .sorted(by: { $0.unixDateCreated > $1.unixDateCreated })
        }
    }
    
    func fetchFirstCompleteGoalBatch() async throws -> [Goal] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.goalsArray
                .filter(where: { $0.isComplete }, limit: FBConstants.goalBatchSize)
                .sorted(by: { $0.unixDateCompleted! > $1.unixDateCompleted! })
        }
    }
    
    func fetchNextIncompleteGoalBatch(before oldestFetchedGoal: Goal) async throws -> [Goal] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.goalsArray
                .filter(where: { !$0.isComplete && $0.unixDateCreated < oldestFetchedGoal.unixDateCreated }, limit: FBConstants.goalBatchSize)
                .sorted(by: { $0.unixDateCreated > $1.unixDateCreated })
        }
    }
    
    func fetchNextCompleteGoalBatch(before leastRecentlyCompletedFetchedGoal: Goal) async throws -> [Goal] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.goalsArray
                .filter(where: { $0.isComplete && $0.unixDateCompleted! < leastRecentlyCompletedFetchedGoal.unixDateCompleted! }, limit: FBConstants.goalBatchSize)
                .sorted(by: { $0.unixDateCompleted! > $1.unixDateCompleted! })
        }
    }
    
    func fetchThreeMostRecentlyCompletedGoals() async throws -> [Goal] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return Array(TestData.goalsArray
                .filter { $0.isComplete }
                .sorted(by: { $0.unixDateCompleted! > $1.unixDateCompleted! })
                .prefix(3))
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
