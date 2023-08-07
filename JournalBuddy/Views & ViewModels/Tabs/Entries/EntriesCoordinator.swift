//
//  EntriesCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import UIKit

@MainActor
final class EntriesCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()
    let navigationController: MainNavigationController
    let currentUser: User

    init(
        navigationController: MainNavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: TabBarCoordinator?,
        currentUser: User
    ) {
        self.navigationController = navigationController
        self.databaseService = databaseService
        self.authService = authService
        let tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "book.circle.fill", withConfiguration: .largeScale), tag: 1)
        self.navigationController.tabBarItem = tabBarItem
        self.parentCoordinator = parentCoordinator
        self.currentUser = currentUser

        super.init()

        self.navigationController.delegate = self
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let entriesViewModel = EntriesViewModel(
            databaseService: databaseService,
            authService: authService,
            currentUser: currentUser
        )
        let entriesViewController = EntriesViewController(coordinator: self, viewModel: entriesViewModel)
        navigationController.pushViewController(entriesViewController, animated: true)
    }

    func presentAddEditTextEntryViewController(withTextEntryToEdit textEntryToEdit: TextEntry?) {
        let addEditTextEntryCoordinator = AddEditTextEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            currentUser: currentUser,
            textEntryToEdit: textEntryToEdit
        )

        childCoordinators.append(addEditTextEntryCoordinator)
        addEditTextEntryCoordinator.start()
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
            }
        }
    }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage errorMessage: String) {
        AlertPresenter.presentBasicErrorAlert(on: viewController, errorMessage: errorMessage)
    }
}

extension EntriesCoordinator: UINavigationControllerDelegate {
    /// Removes the `AddEditTextEntryViewController` from the `childCoordinators` array when the user exits that view controller.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }

        if navigationController.viewControllers.contains(fromViewController) { return }

        if let addEdiTextEntryViewController = fromViewController as? AddEditTextEntryViewController {
            removeChildCoordinator(addEdiTextEntryViewController.coordinator)
        }
    }
}
