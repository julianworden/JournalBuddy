//
//  MainCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

final class MainCoordinator: Coordinator {
    let appWindow: UIWindow?
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController, appWindow: UIWindow?) {
        self.navigationController = navigationController
        self.appWindow = appWindow
    }

    func start() {
        if AuthService.shared.userIsLoggedIn {
            startTabBarCoordinator()
        } else {
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

    func startOnboardingCoordinator() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController, parentCoordinator: self, appWindow: appWindow)
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }

    func startTabBarCoordinator() {
        let tabCoordinator = TabBarCoordinator(parentCoordinator: self, appWindow: appWindow)
        childCoordinators.append(tabCoordinator)
        tabCoordinator.start()
    }

    /// Removes the `OnboardingCoordinator` from the `childCoordinators` array and calls `startTabBarCoordinator` to end onboarding. Called
    /// when a user either logs in successfully or signs up for an account successfully.
    /// - Parameter childCoordinator: The coordinator that was in use when the user either signed in or signed up successfully.
    func childOnboardingCoordinatorDidFinish(_ childCoordinator: OnboardingCoordinator) {
        removeChildCoordinator(childCoordinator)
        navigationController.setViewControllers([], animated: false)
        startTabBarCoordinator()
    }

    /// Removes the `TabBarCoordinator` from the `childCoordinators` array and calls `startOnboardingCoordinator` to end onboarding. Called
    /// when a user either logs in successfully or signs up for an account successfully.
    /// - Parameter childCoordinator: The coordinator that was in use when the user signed out. It is to be removed from the `childCoordinators` array.
    func childTabBarCoordinatorDidFinish(_ childCoordinator: TabBarCoordinator) {
        removeChildCoordinator(childCoordinator)
        startOnboardingCoordinator()
    }
}
