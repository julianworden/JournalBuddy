//
//  GoalsViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Foundation

@MainActor
final class GoalsViewModel: MainViewModel {
    @Published var viewState = GoalsViewState.fetchingGoals
}
