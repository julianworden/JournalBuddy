//
//  GoalsViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Foundation

enum GoalsViewState: ViewState {
    case displayingView, fetchingGoals, error(message: String)
}