//
//  AddEditGoalViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Foundation

enum AddEditGoalViewState: ViewState {
    case displayingView
    case goalIsSaving
    case goalWasSaved
    case goalIsUpdating
    case goalWasUpdated
    case error(message: String)
}
