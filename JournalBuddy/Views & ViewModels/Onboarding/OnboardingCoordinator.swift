//
//  OnboardingCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import FirebaseAuth
import FirebaseAuthInterop
import UIKit

@MainActor
final class OnboardingCoordinator: Coordinator {
    weak var appWindow: UIWindow?
    weak var parentCoordinator: MainCoordinator?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()
    var navigationController: MainNavigationController

    static let preview = OnboardingCoordinator(
        navigationController: MainNavigationController(),
        databaseService: DatabaseService(authService: AuthService()),
        authService: AuthService(),
        parentCoordinator: MainCoordinator.preview,
        appWindow: nil
    )

    init(
        navigationController: MainNavigationController,
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
        let loginViewModel = LoginViewModel(databaseService: databaseService, authService: authService)
        let loginViewController = LoginViewController(coordinator: self, viewModel: loginViewModel)
        navigationController.pushViewController(loginViewController, animated: true)

        appWindow?.rootViewController = navigationController
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

    /// Notifies `parentCoordinator` that the user either logged in or created an account successfully.
    func onboardingDidEnd(for user: User) {
        parentCoordinator?.childOnboardingCoordinatorDidFinish(self, withUser: user)
    }

    func loginViewDidTapSignUpButton() {
        let signUpViewModel = SignUpViewModel(databaseService: databaseService, authService: authService)
        let signUpViewController = SignUpViewController(coordinator: self, viewModel: signUpViewModel)
        navigationController.pushViewController(signUpViewController, animated: true)
    }

    func presentErrorMessage(
        onViewController viewController: UIViewController? = nil,
        errorMessage: String
    ) {
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }
}
