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
        do {
            if let goalToEdit {
                try await updateExistingGoal(goalToEdit)
            } else {
                try await saveNewGoal()
            }
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    private func updateExistingGoal(_ goalToEdit: Goal) async throws {
        guard !goalName.isReallyEmpty else {
            viewState = .error(message: FormError.goalNameIsEmpty.localizedDescription)
            return
        }
        
        guard goalToEdit.name != goalName else {
            viewState = .goalWasUpdated
            return
        }
        
        var updatedGoal = goalToEdit
        updatedGoal.name = goalName
        
        viewState = .goalIsUpdating
        try await databaseService.updateGoal(updatedGoal)
        viewState = .goalWasUpdated
        postGoalSavedNotification(for: updatedGoal)
    }
    
    private func saveNewGoal() async throws {
        guard !goalName.isReallyEmpty else {
            viewState = .error(message: FormError.goalNameIsEmpty.localizedDescription)
            return
        }
        
        let newGoal = Goal(
            id: "",
            creatorUID: currentUser.uid,
            name: goalName
        )
        
        viewState = .goalIsSaving
        let newGoalWithID = try await databaseService.saveNewGoal(newGoal)
        viewState = .goalWasSaved
        postGoalSavedNotification(for: newGoalWithID)
    }
    
    func deleteGoal(_ goal: Goal) async {
        do {
            viewState = .goalIsDeleting
            try await databaseService.deleteGoal(goal)
            postDeletedGoalNotification(for: goal)
            viewState = .goalWasDeleted
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func postGoalSavedNotification(for newGoal: Goal) {
        NotificationCenter.default.post(
            name: .goalWasSaved,
            object: nil,
            userInfo: [NotificationConstants.savedGoal: newGoal]
        )
    }
    
    func postDeletedGoalNotification(for goal: Goal) {
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: goal]
        )
    }
}
