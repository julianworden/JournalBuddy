//
//  GoalsViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Foundation
import Combine

@MainActor
final class GoalsViewModel: MainViewModel {
    enum GoalType: String {
        case incomplete
        case complete
    }
    
    @Published var viewState = GoalsViewState.fetchingGoals
    @Published var completeGoals = [Goal]()
    @Published var incompleteGoals = [Goal]()
    var currentlyDisplayingGoalType = GoalType.incomplete
    var goalsQueryWasPerformed = false

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    var cancellables = Set<AnyCancellable>()
    
    var userHasNoGoals: Bool {
        completeGoals.isEmpty &&
        incompleteGoals.isEmpty
    }

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, currentUser: User) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
    }
    
    func subscribeToPublishers() {
        subscribeToGoalWasSavedPublisher()
        subscribeToGoalWasDeletedPublisher()
    }
    
    /// Updates the appropriate arrays when a goal is saved via `AddEditGoalViewController`.
    func subscribeToGoalWasSavedPublisher() {
        NotificationCenter.default.publisher(for: .goalWasSaved)
            .sink { [weak self] notification in
                guard let newGoal = notification.userInfo?[NotificationConstants.savedGoal] as? Goal else {
                    print("❌ goalWasSaved notification posted without entry info.")
                    return
                }
                
                self?.addGoalToArrays(newGoal)
                self?.setViewState()
            }
            .store(in: &cancellables)
    }
    
    /// Updates the appropriate arrays when a goal is deleted via `AddEditGoalViewController`.
    func subscribeToGoalWasDeletedPublisher() {
        NotificationCenter.default.publisher(for: .goalWasDeleted)
            .sink { [weak self] notification in
                guard let deletedGoal = notification.userInfo?[NotificationConstants.deletedGoal] as? Goal else {
                    return
                }
                
                self?.removeGoalFromArray(deletedGoal)
                self?.setViewState()
            }
            .store(in: &cancellables)
    }
    
    /// Fetches the first batch of the user's most recently completed goals and most recently created incomplete goals from Firestore and
    /// assigns them to the appropriate arrays. The amount of each type of goals that are fetched is set in `FBConstants.goalBatchSize`.
    /// - Parameter performGoalQuery: Makes it possible to test case where no goals are found. Defaults to true
    /// because this property should never be used in production.
    func fetchFirstGoalBatch(performGoalQuery: Bool = true) async {
        do {
            viewState = .fetchingGoals
            if performGoalQuery {
                async let incompleteGoals = try await databaseService.fetchFirstIncompleteGoalBatch()
                async let completeGoals = try await databaseService.fetchFirstCompleteGoalBatch()
                self.incompleteGoals = try await incompleteGoals
                self.completeGoals = try await completeGoals
            }
            
            setViewState()
            goalsQueryWasPerformed = true
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func fetchNextIncompleteGoalBatch() async {
        do {
            guard let leastRecentlyCreatedFetchedIncompleteGoal = incompleteGoals.last else {
                print("❌ Attempted to fetch next incomplete goal batch before any incomplete goals have been fetched.")
                return
            }
            
            let nextIncompleteGoalsBatch = try await databaseService.fetchNextIncompleteGoalBatch(
                before: leastRecentlyCreatedFetchedIncompleteGoal
            )
            incompleteGoals.append(contentsOf: nextIncompleteGoalsBatch)
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func fetchNextCompleteGoalBatch() async {
        do {
            guard let leastRecentlyCompletedFetchedCompleteGoal = completeGoals.last else {
                print("❌ Attempted to fetch next complete goal batch before any complete goals have been fetched.")
                return
            }
            
            let nextCompleteGoalsBatch = try await databaseService.fetchNextCompleteGoalBatch(
                before: leastRecentlyCompletedFetchedCompleteGoal
            )
            completeGoals.append(contentsOf: nextCompleteGoalsBatch)
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Changes a given goal's `isComplete` property to true. Updates Firestore and the arrays accordingly.
    /// - Parameter goal: The goal that is to be complete.
    func completeGoal(_ goal: Goal) async throws {
        guard !goal.isComplete else {
            print("❌ Attempted to complete a goal that has already been completed.")
            return
        }
        
        removeGoalFromArray(goal)
        
        var completedGoal = goal
        completedGoal.complete()
        
        addGoalToArrays(completedGoal)
        
        setViewState()
        
        try await databaseService.completeGoal(completedGoal)
        postGoalWasCompletedNotification(completedGoal)
    }
    
    func postGoalWasCompletedNotification(_ completedGoal: Goal) {
        NotificationCenter.default.post(
            name: .goalWasCompleted,
            object: nil,
            userInfo: [NotificationConstants.completedGoal: completedGoal]
        )
    }
    
    /// Deletes a given goal from the appropriate arrays and from Firestore.
    /// - Parameter goal: The goal to delete.
    func deleteGoal(_ goal: Goal) async {
        do {
            removeGoalFromArray(goal)
            setViewState()
            try await databaseService.deleteGoal(goal)
            postGoalWasDeletedNotification(goal)
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func postGoalWasDeletedNotification(_ deletedGoal: Goal) {
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: deletedGoal]
        )
    }
    
    /// Adds a given goal to the `goals` array. Also adds the given goal to the `incompleteGoals`
    /// or `completeGoals` arrays depending on whether or not the goal is complete.
    /// - Parameter goalToRemove: The goal to add to the arrays.
    func addGoalToArrays(_ goalToAdd: Goal) {
        if goalToAdd.isComplete {
            completeGoals.insert(goalToAdd, at: 0)
        } else {
            incompleteGoals.insert(goalToAdd, at: 0)
        }
    }
    
    /// Removes a given goal from the `goals` array. Also removes the given goal from the `incompleteGoals`
    /// or `completeGoals` arrays depending on whether or not the goal is complete. Call `setViewState()` after
    /// this method to update the UI accordingly.
    /// - Parameter goalToRemove: The goal to remove from the arrays.
    func removeGoalFromArray(_ goalToRemove: Goal) {
        if goalToRemove.isComplete {
            guard let completeGoalsIndex = completeGoals.firstIndex(of: goalToRemove) else {
                return
            }
            
            completeGoals.remove(at: completeGoalsIndex)
        } else {
            guard let incompleteGoalsIndex = incompleteGoals.firstIndex(of: goalToRemove) else {
                return
            }
            
            incompleteGoals.remove(at: incompleteGoalsIndex)
        }
    }
    
    /// Analyzes the state of the `Goals`, `incompleteGoals`, and `compelteGoals` arrays to determine
    /// what the view state should be. Called after any updates to any of these arrays occur. Call `setViewState()` after
    /// this method to update the UI accordingly.
    func setViewState() {
        if userHasNoGoals {
            viewState = .noGoalsFound
        } else if completeGoals.isEmpty {
            viewState = .noCompleteGoalsFound
        } else if incompleteGoals.isEmpty {
            viewState = .noIncompleteGoalsFound
        } else {
            viewState = .fetchedGoals
        }
    }
}
