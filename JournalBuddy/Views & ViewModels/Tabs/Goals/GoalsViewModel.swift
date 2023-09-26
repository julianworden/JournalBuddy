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
    @Published var goals = [Goal]()
    @Published var completeGoals = [Goal]()
    @Published var incompleteGoals = [Goal]()
    var currentlyDisplayingGoalType = GoalType.incomplete
    var goalsQueryWasPerformed = false

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    var cancellables = Set<AnyCancellable>()

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
                    print("❌ Array does not contain selected goal.")
                    return
                }
                
                self?.removeGoalFromArrays(deletedGoal)
                self?.setViewState()
            }
            .store(in: &cancellables)
    }
    
    /// Fetches all the user's goals from Firestore and assigns them to the appropriate arrays.
    /// - Parameter performGoalQuery: Makes it possible to test case where no goals are found. Defaults to true
    /// because this property should never be used in production.
    func fetchGoals(performGoalQuery: Bool = true) async {
        do {
            viewState = .fetchingGoals
            if performGoalQuery {
                goals = try await databaseService.fetchGoals()
            }
            
            if goals.isEmpty {
                viewState = .noGoalsFound
            } else {
                completeGoals = goals.filter { $0.isComplete }
                incompleteGoals = goals.filter { !$0.isComplete }
                
                setViewState()
            }
            
            goalsQueryWasPerformed = true
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
        
        removeGoalFromArrays(goal)
        
        var completedGoal = goal
        completedGoal.isComplete = true
        
        addGoalToArrays(completedGoal)
        
        setViewState()
        
        try await databaseService.completeGoal(completedGoal)
    }
    
    /// Deletes a given goal from the appropriate arrays and from Firestore.
    /// - Parameter goal: The goal to delete.
    func deleteGoal(_ goal: Goal) async {
        do {
            removeGoalFromArrays(goal)
            setViewState()
            try await databaseService.deleteGoal(goal)
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Adds a given goal to the `goals` array. Also adds the given goal to the `incompleteGoals`
    /// or `completeGoals` arrays depending on whether or not the goal is complete.
    /// - Parameter goalToRemove: The goal to add to the arrays.
    func addGoalToArrays(_ goalToAdd: Goal) {
        goals.append(goalToAdd)
        
        if goalToAdd.isComplete {
            completeGoals.append(goalToAdd)
        } else {
            incompleteGoals.append(goalToAdd)
        }
    }
    
    /// Removes a given goal from the `goals` array. Also removes the given goal from the `incompleteGoals`
    /// or `completeGoals` arrays depending on whether or not the goal is complete. Call `setViewState()` after
    /// this method to update the UI accordingly.
    /// - Parameter goalToRemove: The goal to remove from the arrays.
    func removeGoalFromArrays(_ goalToRemove: Goal) {
        if goalToRemove.isComplete {
            guard let completeGoalsIndex = completeGoals.firstIndex(of: goalToRemove),
                  let goalsIndex = goals.firstIndex(of: goalToRemove) else {
                print("❌ Array does not contain selected goal.")
                return
            }
            
            completeGoals.remove(at: completeGoalsIndex)
            goals.remove(at: goalsIndex)
        } else {
            guard let incompleteGoalsIndex = incompleteGoals.firstIndex(of: goalToRemove),
                  let goalsIndex = goals.firstIndex(of: goalToRemove) else {
                print("❌ Array does not contain selected goal.")
                return
            }
            
            incompleteGoals.remove(at: incompleteGoalsIndex)
            goals.remove(at: goalsIndex)
        }
    }
    
    /// Analyzes the state of the `Goals`, `incompleteGoals`, and `compelteGoals` arrays to determine
    /// what the view state should be. Called after any updates to any of these arrays occur. Call `setViewState()` after
    /// this method to update the UI accordingly.
    func setViewState() {
        if goals.isEmpty {
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
