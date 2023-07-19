//
//  OnboardingCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

final class OnboardingCoordinator: Coordinator {
    var appWindow: UIWindow?
    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController, parentCoordinator: MainCoordinator, appWindow: UIWindow?) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.appWindow = appWindow
    }

    func start() {
        let loginViewController = LoginViewController(coordinator: self)
        navigationController.pushViewController(loginViewController, animated: true)

        appWindow?.rootViewController = navigationController
        appWindow?.makeKeyAndVisible()
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
            }
        }
    }

    func userDidLogIn() {
        parentCoordinator?.childOnboardingCoordinatorDidFinish(self)
    }
}
