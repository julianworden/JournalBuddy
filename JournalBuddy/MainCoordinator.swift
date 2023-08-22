//
//  MainCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import FirebaseAuth
import UIKit

@MainActor
final class MainCoordinator: Coordinator {
    let appWindow: UIWindow?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var currentUser: User?
    var childCoordinators = [Coordinator]()
    var navigationController: MainNavigationController?

    static let preview = MainCoordinator(
        databaseService: DatabaseService(authService: AuthService()),
        authService: AuthService(),
        appWindow: nil,
        currentUser: User.example
    )

    init(databaseService: DatabaseServiceProtocol, authService: AuthServiceProtocol, appWindow: UIWindow?, currentUser: User?) {
        self.databaseService = databaseService
        self.authService = authService
        self.appWindow = appWindow
        self.currentUser = currentUser
    }

    func start() {
        if let currentUser {
            startTabBarCoordinator(withUser: currentUser)
        } else {
            navigationController = MainNavigationController()
            startOnboardingCoordinator()
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
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
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

    func startTabBarCoordinator(withUser user: User) {
        let tabCoordinator = TabBarCoordinator(
            appWindow: appWindow,
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            currentUser: user
        )

        childCoordinators.append(tabCoordinator)
        tabCoordinator.start()
    }

    /// Removes the `OnboardingCoordinator` from the `childCoordinators` array and calls `startTabBarCoordinator` to end onboarding. Called when a user either logs in successfully or signs up for an account successfully.
    /// - Parameter childCoordinator: The coordinator that was in use when the user either signed in or signed up successfully.
    func childOnboardingCoordinatorDidFinish(_ childCoordinator: OnboardingCoordinator, withUser user: User) {
        removeChildCoordinator(childCoordinator)
        navigationController = nil
        startTabBarCoordinator(withUser: user)
    }

    /// Removes the `TabBarCoordinator` from the `childCoordinators` array and calls `startOnboardingCoordinator` to end onboarding. Called when a user logs out.
    /// - Parameter childCoordinator: The coordinator that was in use when the user logged out. It is to be removed from the `childCoordinators` array.
    func childTabBarCoordinatorDidFinish(_ childCoordinator: TabBarCoordinator) {
        removeChildCoordinator(childCoordinator)
        self.navigationController = MainNavigationController()
        startOnboardingCoordinator()
    }
}
