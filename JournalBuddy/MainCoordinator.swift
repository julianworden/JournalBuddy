//
//  MainCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

final class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        // TODO: Check if user is signed in. If they are, use OnboardingCoordinator. Otherwise, use tab bar coordinator.

        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController, parentCoordinator: self)
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }

    /// Removes the `OnboardingCoordinator` from the `childCoordinators` array and calls `startHomeCoordinator` to end onboarding. Called
    /// when a user either logs in successfully or signs up for an account successfully.
    /// - Parameter childCoordinator: The coordinator that was in use when the user either signed in or signed up successfully.
    func childOnboardingCoordinatorDidFinish(_ childCoordinator: OnboardingCoordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
                startHomeCoordinator()
            }
        }
    }

    func startHomeCoordinator() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, parentCoordinator: self)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
}
