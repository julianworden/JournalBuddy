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
    @Published var viewState = GoalsViewState.fetchedGoals
    @Published var goals = [Goal]()

    var cancellables = Set<AnyCancellable>()
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, currentUser: User) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
        
        subscribeToPublishers()
    }
    
    func fetchGoals() async {
        do {
            viewState = .fetchingGoals
            goals = try await databaseService.fetchGoals()
            viewState = .fetchedGoals
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func subscribeToPublishers() {
        NotificationCenter.default.publisher(for: .goalWasSaved)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchGoals()
                }
            }
            .store(in: &cancellables)
    }
}
