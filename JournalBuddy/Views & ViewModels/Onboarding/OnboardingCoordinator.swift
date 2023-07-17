//
//  OnboardingCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

final class OnboardingCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController, parentCoordinator: MainCoordinator) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }

    func start() {
        let loginViewController = LoginViewController(coordinator: self)
        navigationController.pushViewController(loginViewController, animated: true)
    }

    func userDidLogIn() {
        parentCoordinator?.childOnboardingCoordinatorDidFinish(self)
    }
}
