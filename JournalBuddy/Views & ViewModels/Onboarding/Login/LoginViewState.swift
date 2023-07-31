//
//  LoginViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/20/23.
//

import Foundation

enum LoginViewState: ViewState {
    case displayingView, loggingIn, loggedIn(User), error(String)
}
