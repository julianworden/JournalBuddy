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
    @discardableResult func saveEntry<T: Entry>(_ entry: T, at url: URL?) async throws -> T
    func updateEntry<T: Entry>(_ entry: T) async throws
    func deleteEntry<T: Entry>(_ entry: T) async throws

    func fetchTextEntries(forUID uid: String) async throws -> [TextEntry]
    
    func fetchGoals() async throws -> [Goal]
    func saveNewGoal(_ newGoal: Goal) async throws -> Goal
    /// Updates a given goal in Firestore.
    /// - Parameter updatedGoal: The updated goal that is to be saved to
    /// Firestore. This goal should contain the new, updated info before it's passed
    /// into this method.
    func updateGoal(_ updatedGoal: Goal) async throws
    /// Updates an existing goal in Firestore with an `isComplete` status of `true`.
    /// - Parameter completedGoal: The updated goal that is to be saved
    /// to firestore. This goal should already have its `isComplete` property
    /// set to `true` before its passed into this method.
    func completeGoal(_ completedGoal: Goal) async throws
    func deleteGoal(_ goalToDelete: Goal) async throws
}
