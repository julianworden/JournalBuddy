//
//  AddEditGoalViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Foundation

@MainActor
final class AddEditGoalViewModel: MainViewModel {
    @Published var viewState = AddEditGoalViewState.displayingView
    var goalToEdit: Goal?
    
    var goalName = ""
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    
    var navigationTitle: String {
        if goalToEdit != nil {
            return "Edit Goal"
        } else {
            return "Create Goal"
        }
    }
    
    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        currentUser: User,
        goalToEdit: Goal?
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
        self.goalToEdit = goalToEdit
        self.goalName = goalToEdit?.name ?? ""
    }
    
    func saveButtonTapped() async {
        if let goalToEdit {
            updateExistingGoal(goalToEdit)
        } else {
            await saveNewGoal()
        }
    }
    
    func updateExistingGoal(_ goalToEdit: Goal) {
        #warning("Implement this")
    }
    
    func saveNewGoal() async {
        guard !goalName.isReallyEmpty else {
            viewState = .error(message: FormError.goalNameIsEmpty.localizedDescription)
            return
        }
        
        do {
            let newGoal = Goal(
                id: "",
                name: goalName,
                creatorUID: currentUser.uid
            )
            
            viewState = .goalIsSaving
            try await databaseService.saveNewGoal(newGoal)
            viewState = .goalWasSaved
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
}
