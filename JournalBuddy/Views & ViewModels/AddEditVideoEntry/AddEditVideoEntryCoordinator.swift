//
//  AddEditVideoEntryCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import UIKit

@MainActor
final class AddEditVideoEntryCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var databaseService: DatabaseServiceProtocol
    var authService: AuthServiceProtocol
    let navigationController: MainNavigationController
    let currentUser: User

    init(
        parentCoordinator: Coordinator?,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        navigationController: MainNavigationController,
        currentUser: User
    ) {
        self.parentCoordinator = parentCoordinator
        self.databaseService = databaseService
        self.authService = authService
        self.navigationController = navigationController
        self.currentUser = currentUser
    }

    func start() {
        let addEditVideoEntryViewModel = AddEditVideoEntryViewModel()
        let addEditVideoEntryViewController = AddEditVideoEntryViewController(
            coordinator: self,
            viewModel: addEditVideoEntryViewModel
        )

        navigationController.pushViewController(addEditVideoEntryViewController, animated: true)
    }
    
    func removeChildCoordinator(_ childCoordinator: Coordinator?) { }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage errorMessage: String) {
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }
}
