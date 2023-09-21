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
    @Published var viewState = GoalsViewState.fetchingGoals
    @Published var goals = [Goal]()
    @Published var completeGoals = [Goal]()
    @Published var incompleteGoals = [Goal]()
    var currentlyDisplayingGoalType = GoalType.incomplete

    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    var cancellables = Set<AnyCancellable>()

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, currentUser: User) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
    }
    
    func fetchGoals() async {
        do {
            viewState = .fetchingGoals
            goals = try await databaseService.fetchGoals()
            completeGoals = goals.filter { $0.isComplete }
            incompleteGoals = goals.filter { !$0.isComplete }
            viewState = .fetchedGoals
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func completeGoal(_ goal: Goal) async throws {
        guard let completedGoalIndex = incompleteGoals.firstIndex(of: goal) else {
            print("❌ incompleteGoals array does not contain selected goal.")
            return
        }
        
        var completedGoal = goal
        completedGoal.isComplete = true
        
        incompleteGoals.remove(at: completedGoalIndex)
        completeGoals.append(completedGoal)
        
        try await databaseService.completeGoal(completedGoal)
    }
    
    func subscribeToPublishers() {
        NotificationCenter.default.publisher(for: .goalWasSaved)
            .sink { [weak self] notification in
                guard let newGoal = notification.userInfo?[NotificationConstants.savedGoal] as? Goal else {
                    return
                }
                
                if newGoal.isComplete {
                    self?.completeGoals.append(newGoal)
                } else {
                    self?.incompleteGoals.append(newGoal)
                }
            }
            .store(in: &cancellables)
    }
}
