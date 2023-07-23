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
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        databaseService: DatabaseServiceProtocol,
        parentCoordinator: TabBarCoordinator?
    ) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        self.databaseService = databaseService
        self.parentCoordinator = parentCoordinator
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let homeViewController = HomeViewController(coordinator: self)
        navigationController.pushViewController(homeViewController, animated: true)
    }

    func presentNewTextEntryViewController() {
        let newTextEntryViewModel = NewTextEntryViewModel(databaseService: databaseService)
        let newTextEntryViewController = NewTextEntryViewController(coordinator: self, viewModel: newTextEntryViewModel)
        navigationController.pushViewController(newTextEntryViewController, animated: true)
    }

    func newTextEntryViewControllerDidCreateEntry() {
        navigationController.popViewController(animated: true)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) { }

    func userLoggedOut() {
        parentCoordinator?.childDidLogOut(self)
    }
}
