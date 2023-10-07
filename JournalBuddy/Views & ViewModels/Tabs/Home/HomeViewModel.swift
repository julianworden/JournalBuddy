//
//  HomeViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: MainViewModel {
    @Published var viewState = HomeViewState.displayingView
    @Published var threeMostRecentlyCompletedGoals = [Goal]()
    /// When set to true, `HomeAccomplishmentsSection` that its stack view of recently completed goals should update.
    /// This will occur when a complete goal is deleted or an incomplete goal is completed.
    @Published var refreshGoalsList = false

    let databaseService: DatabaseServiceProtocol
    var cancellables = Set<AnyCancellable>()
    let authService: AuthServiceProtocol
    var currentUser: User

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, currentUser: User) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
        
        subscribeToPublishers()
    }
    
    func fetchThreeMostRecentlyCompletedGoals() async {
        do {
            threeMostRecentlyCompletedGoals = try await databaseService.fetchThreeMostRecentlyCompletedGoals()
            refreshGoalsList = true
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }

    func logOut() {
        do {
            try authService.logOut()
            viewState = .userLoggedOut
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func subscribeToPublishers() {
        subscribeToGoalWasCompletedNotification()
        subscribeToGoalWasDeletedNotification()
    }
    
    func subscribeToGoalWasCompletedNotification() {
        NotificationCenter.default.publisher(for: .goalWasCompleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let completedGoal = notification.userInfo?[NotificationConstants.completedGoal] as? Goal else {
                    print("❌ Received completedGoal notification without completedGoal info.")
                    return
                }
                
                if threeMostRecentlyCompletedGoals.count == 3 {
                    threeMostRecentlyCompletedGoals.removeLast()
                }
                
                threeMostRecentlyCompletedGoals.insert(completedGoal, at: 0)
                refreshGoalsList = true
            }
            .store(in: &cancellables)
    }
    
    func subscribeToGoalWasDeletedNotification() {
        NotificationCenter.default.publisher(for: .goalWasDeleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let deletedGoal = notification.userInfo?[NotificationConstants.deletedGoal] as? Goal else {
                    print("❌ Received deletedGoal notification without deletedGoal info.")
                    return
                }
                
                if let deletedGoalIndex = self.threeMostRecentlyCompletedGoals.firstIndex(of: deletedGoal) {
                    let goalsCountBeforeUpdate = threeMostRecentlyCompletedGoals.count
                    
                    self.threeMostRecentlyCompletedGoals.remove(at: deletedGoalIndex)
                    
                    if goalsCountBeforeUpdate == 3 {
                        Task {
                            await self.fetchThreeMostRecentlyCompletedGoals()
                        }
                    }
                    
                    self.refreshGoalsList = true
                }
            }
            .store(in: &cancellables)
    }
}

