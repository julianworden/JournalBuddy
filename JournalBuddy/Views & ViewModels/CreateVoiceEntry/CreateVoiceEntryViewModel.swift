//
//  CreateVoiceEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Foundation

@MainActor
final class CreateVoiceEntryViewModel: MainViewModel {
    @Published var viewState = CreateVoiceEntryViewState.displayingView
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    
    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        currentUser: User
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
    }
}
