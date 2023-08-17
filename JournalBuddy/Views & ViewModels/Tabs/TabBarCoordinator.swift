//
//  TabBarCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import UIKit

/// A Coordinator that manages hiding and showing the `UITabBarController` that appears either when the user opens the app while already
/// being signed in, or when the user logs in.
@MainActor
final class TabBarCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?
    weak var appWindow: UIWindow?
    let currentUser: User
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()

    init(
        appWindow: UIWindow?,
        parentCoordinator: MainCoordinator,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        currentUser: User
    ) {
        self.parentCoordinator = parentCoordinator
        self.currentUser = currentUser
        self.appWindow = appWindow
        self.databaseService = databaseService
        self.authService = authService
    }

    func start() {
        let tabBarController = MainTabBarController(
            coordinator: self,
            databaseService: databaseService,
            authService: authService,
            currentUser: currentUser
        )
        
        appWindow?.rootViewController = tabBarController
        appWindow?.makeKeyAndVisible()

        if let appWindow {
            UIView.transition(with: appWindow, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        }
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

    /// Called by each `UITabBarItem` to notify the parent that a new item's coordinator was created.
    /// - Parameter coordinator: The coordinator that was created and is to be appended to the `childCoordinators` array.
    func childWasCreated(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func childDidLogOut() {
        parentCoordinator?.childTabBarCoordinatorDidFinish(self)
    }
}
