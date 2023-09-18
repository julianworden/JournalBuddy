//
//  AddEditGoalViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Foundation

@MainActor
final class AddEditGoalViewModel: MainViewModel {
    var goalToEdit: Goal?
    var viewState = AddEditGoalViewState.displayingView
    
    var navigationTitle: String {
        if goalToEdit != nil {
            return "Edit Goal"
        } else {
            return "Create Goal"
        }
    }
    
    init(goalToEdit: Goal?) {
        self.goalToEdit = goalToEdit
    }
}
