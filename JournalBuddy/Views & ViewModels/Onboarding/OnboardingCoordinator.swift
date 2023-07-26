//
//  OnboardingCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

@MainActor
final class OnboardingCoordinator: Coordinator {
    weak var appWindow: UIWindow?
    weak var parentCoordinator: MainCoordinator?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: MainCoordinator,
        appWindow: UIWindow?
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.databaseService = databaseService
        self.authService = authService
        self.appWindow = appWindow
    }

    func start() {
        let loginViewController = LoginViewController(coordinator: self)
        navigationController.pushViewController(loginViewController, animated: true)

        appWindow?.rootViewController = navigationController
        appWindow?.makeKeyAndVisible()

        if let appWindow {
            UIView.transition(with: appWindow, duration: 0.5, options: .transitionCurlDown, animations: nil)
        }
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
            }
        }
    }

    /// Notifies `parentCoordinator` that the user either logged in or created an account successfully.
    func onboardingDidEnd() {
        parentCoordinator?.childOnboardingCoordinatorDidFinish(self)
    }

    func loginViewDidTapSignUpButton() {
        let signUpViewModel = SignUpViewModel(databaseService: databaseService, authService: authService)
        let signUpViewController = SignUpViewController(coordinator: self, viewModel: signUpViewModel)
        navigationController.pushViewController(signUpViewController, animated: true)
    }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage message: String) {
        AlertPresenter.presentBasicErrorAlert(on: viewController, errorMessage: message)
    }
}
