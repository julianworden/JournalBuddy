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
    var textEntryToEdit: TextEntry?

    init(
        parentCoordinator: Coordinator,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        navigationController: UINavigationController,
        textEntryToEdit: TextEntry?
    ) {
        self.parentCoordinator = parentCoordinator
        self.databaseService = databaseService
        self.authService = authService
        self.navigationController = navigationController
        self.textEntryToEdit = textEntryToEdit
    }

    func start() {
        let addEditTextEntryViewModel = AddEditTextEntryViewModel(
            databaseService: databaseService,
            authService: authService,
            textEntryToEdit: textEntryToEdit
        )
        let addEditTextEntryViewController = AddEditTextEntryViewController(
            coordinator: self,
            viewModel: addEditTextEntryViewModel
        )

        navigationController.pushViewController(addEditTextEntryViewController, animated: true)
    }

    func addEditTextEntryViewControllerDidSaveTextEntry() {
        navigationController.popViewController(animated: true)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator?) { }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage message: String) { }
}
