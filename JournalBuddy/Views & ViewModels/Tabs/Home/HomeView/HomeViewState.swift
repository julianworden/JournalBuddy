//
//  HomeViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/20/23.
//

import Foundation

enum HomeViewState: ViewState {
    case displayingView, userLoggedOut, error(String)
}
