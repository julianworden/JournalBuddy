//
//  HomeCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

@MainActor
final class HomeCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    var childCoordinators = [Coordinator]()
    var navigationController: MainNavigationController

    init(
        navigationController: MainNavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: TabBarCoordinator?,
        currentUser: User
    ) {
        self.navigationController = navigationController
        self.navigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.circle.fill", withConfiguration: .largeScale), tag: 0)
        self.databaseService = databaseService
        self.authService = authService
        self.parentCoordinator = parentCoordinator
        self.currentUser = currentUser

        super.init()

        self.navigationController.delegate = self
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let homeViewModel = HomeViewModel(
            databaseService: databaseService,
            authService: authService,
            currentUser: currentUser
        )

        let homeViewController = HomeViewController(coordinator: self, viewModel: homeViewModel)
        navigationController.pushViewController(homeViewController, animated: true)
    }

    func presentNewTextEntryViewController() {
        let addEditTextEntryCoordinator = AddEditTextEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            currentUser: currentUser,
            textEntryToEdit: nil
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
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }

    func userLoggedOut() {
        parentCoordinator?.childDidLogOut()
    }
}

extension HomeCoordinator: UINavigationControllerDelegate {
    /// Removes the `AddEditTextEntryViewController` from the `childCoordinators` array when the user exits that view controller.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }

        if navigationController.viewControllers.contains(fromViewController) { return }

        if let addEditTextEntryViewController = fromViewController as? AddEditTextEntryViewController {
            removeChildCoordinator(addEditTextEntryViewController.coordinator)
        }
    }
}
