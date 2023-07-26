//
//  HomeCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

@MainActor
final class HomeCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: TabBarCoordinator?
    ) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        self.databaseService = databaseService
        self.authService = authService
        self.parentCoordinator = parentCoordinator
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let homeViewModel = HomeViewModel(
            databaseService: databaseService,
            authService: authService
        )

        let homeViewController = HomeViewController(coordinator: self, viewModel: homeViewModel)
        navigationController.pushViewController(homeViewController, animated: true)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) { }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage message: String) {
        AlertPresenter.presentBasicErrorAlert(on: viewController, errorMessage: message)
    }

    func presentNewTextEntryViewController() {
        let newTextEntryViewModel = NewTextEntryViewModel(
            databaseService: databaseService,
            authService: authService
        )
        
        let newTextEntryViewController = NewTextEntryViewController(coordinator: self, viewModel: newTextEntryViewModel)
        navigationController.pushViewController(newTextEntryViewController, animated: true)
    }

    func newTextEntryViewControllerDidCreateEntry() {
        navigationController.popViewController(animated: true)
    }

    func userLoggedOut() {
        parentCoordinator?.childDidLogOut(self)
    }
}
