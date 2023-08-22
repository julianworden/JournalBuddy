//
//  GoalsCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import UIKit

@MainActor
final class GoalsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: TabBarCoordinator?
    let currentUser: User
    let navigationController: MainNavigationController
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    init(
        navigationController: MainNavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: TabBarCoordinator?,
        currentUser: User
    ) {
        self.parentCoordinator = parentCoordinator
        self.currentUser = currentUser
        self.navigationController = navigationController
        self.navigationController.tabBarItem = UITabBarItem(title: "Goals", image: UIImage(systemName: "trophy.circle.fill", withConfiguration: .largeScale), tag: 2)
        self.databaseService = databaseService
        self.authService = authService

        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let goalsViewModel = GoalsViewModel()
        let goalsViewController = GoalsViewController(coordinator: self, viewModel: goalsViewModel)

        navigationController.pushViewController(goalsViewController, animated: true)
    }
    
    func removeChildCoordinator(_ childCoordinator: Coordinator?) { }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage errorMessage: String) {
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }
}
