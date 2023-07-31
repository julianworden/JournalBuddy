//
//  SignUpViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

enum SignUpViewState: ViewState {
    case displayingView, creatingAccount, accountCreatedSuccessfully(for: User), error(String)
}
