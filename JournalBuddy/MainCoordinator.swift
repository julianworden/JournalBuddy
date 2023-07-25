//
//  MainCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

@MainActor
final class MainCoordinator: Coordinator {
    let appWindow: UIWindow?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController?

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, appWindow: UIWindow?) {
        self.databaseService = databaseService
        self.authService = authService
        self.appWindow = appWindow
    }

    func start() {
        if authService.userIsLoggedIn {
            startTabBarCoordinator()
        } else {
            navigationController = UINavigationController()
            navigationController?.navigationBar.prefersLargeTitles = true
            startOnboardingCoordinator()
        }
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
            }
        }
    }

    func viewController(_ viewController: UIViewController, shouldPresentError error: Error) {
        AlertPresenter.presentBasicErrorAlert(on: viewController, error: error)
    }

    func startOnboardingCoordinator() {
        guard let navigationController else {
            print(ErrorMessageConstants.mainCoordinatorMissingNavigationController)
            return
        }

        let onboardingCoordinator = OnboardingCoordinator(
            navigationController: navigationController,
            databaseService: databaseService,
            authService: authService,
            parentCoordinator: self,
            appWindow: appWindow
        )

        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }

    func startTabBarCoordinator() {
        let tabCoordinator = TabBarCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            appWindow: appWindow
        )

        childCoordinators.append(tabCoordinator)
        tabCoordinator.start()
    }

    /// Removes the `OnboardingCoordinator` from the `childCoordinators` array and calls `startTabBarCoordinator` to end onboarding. Called
    /// when a user either logs in successfully or signs up for an account successfully.
    /// - Parameter childCoordinator: The coordinator that was in use when the user either signed in or signed up successfully.
    func childOnboardingCoordinatorDidFinish(_ childCoordinator: OnboardingCoordinator) {
        removeChildCoordinator(childCoordinator)
        navigationController = nil
        startTabBarCoordinator()
    }

    /// Removes the `TabBarCoordinator` from the `childCoordinators` array and calls `startOnboardingCoordinator` to end onboarding. Called
    /// when a user either logs in successfully or signs up for an account successfully.
    /// - Parameter childCoordinator: The coordinator that was in use when the user signed out. It is to be removed from the `childCoordinators` array.
    func childTabBarCoordinatorDidFinish(_ childCoordinator: TabBarCoordinator) {
        removeChildCoordinator(childCoordinator)
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController = navigationController
        startOnboardingCoordinator()
    }
}
