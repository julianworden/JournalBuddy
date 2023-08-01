//
//  AddEditTextEntryCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/30/23.
//

import UIKit

@MainActor
final class AddEditTextEntryCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let navigationController: UINavigationController
    let currentUser: User
    var textEntryToEdit: TextEntry?

    init(
        parentCoordinator: Coordinator,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        navigationController: UINavigationController,
        currentUser: User,
        textEntryToEdit: TextEntry?
    ) {
        self.parentCoordinator = parentCoordinator
        self.databaseService = databaseService
        self.authService = authService
        self.navigationController = navigationController
        self.currentUser = currentUser
        self.textEntryToEdit = textEntryToEdit
    }

    func start() {
        let addEditTextEntryViewModel = AddEditTextEntryViewModel(
            databaseService: databaseService,
            authService: authService,
            currentUser: currentUser,
            textEntryToEdit: textEntryToEdit
        )
        let addEditTextEntryViewController = AddEditTextEntryViewController(
            coordinator: self,
            viewModel: addEditTextEntryViewModel
        )

        navigationController.pushViewController(addEditTextEntryViewController, animated: true)
    }
    
    /// Dismisses `AddEditTextEntryViewController` when a `TextEntry` has been edited, created, or deleted.
    func addEditTextEntryViewControllerDidEditTextEntry() {
        navigationController.popViewController(animated: true)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator?) { }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage errorMessage: String) {
        AlertPresenter.presentBasicErrorAlert(on: viewController, errorMessage: errorMessage)
    }
}
