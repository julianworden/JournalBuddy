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
    
    var saveButtonText: String {
        if goalToEdit != nil {
            return "Update"
        } else {
            return "Save"
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
            await updateExistingGoal(goalToEdit)
        } else {
            await saveNewGoal()
        }
    }
    
    func updateExistingGoal(_ goalToEdit: Goal) async {
        guard goalToEdit.name != goalName else {
            viewState = .goalWasSaved
            return
        }
        
        do {
            var updatedGoal = goalToEdit
            updatedGoal.name = goalName
            
            viewState = .goalIsSaving
            try await databaseService.updateGoal(updatedGoal)
            viewState = .goalWasSaved
            postGoalSavedNotification()
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
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
            postGoalSavedNotification()
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func postGoalSavedNotification() {
        NotificationCenter.default.post(name: .goalWasSaved, object: nil)
    }
}
