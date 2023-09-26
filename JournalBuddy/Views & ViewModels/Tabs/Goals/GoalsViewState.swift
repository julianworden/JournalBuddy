//
//  GoalsViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Foundation

enum GoalsViewState: ViewState {
    /// Set while the view model is fetching goals from Firestore.
    case fetchingGoals
    /// Set after the view model has fetched goals that occupy both its `completedGoals` and `incompleteGoals` arrays.
    case fetchedGoals
    /// Set after the view model has successfully attempted to fetch goals from Firestore, but no goals of any kind were found.
    case noGoalsFound
    /// Set after the view model has successfully fetched complete goals from Firestore, but no incomplete goals were found.
    case noIncompleteGoalsFound
    /// Set after the view model has successfully fetched incomplete goals from Firestore, but no complete goals were found.
    case noCompleteGoalsFound
    case error(message: String)
}
