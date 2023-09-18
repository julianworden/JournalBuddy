//
//  GoalsViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Foundation

@MainActor
final class GoalsViewModel: MainViewModel {
    @Published var viewState = GoalsViewState.fetchedGoals
    @Published var goals = [
        Goal(id: UUID().uuidString, name: "Go to college"),
        Goal(id: UUID().uuidString, name: "Pay off student loans")
    ]
}
