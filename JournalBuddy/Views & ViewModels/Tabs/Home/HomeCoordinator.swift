//
//  HomeCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

final class HomeCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController, parentCoordinator: TabBarCoordinator?) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        self.parentCoordinator = parentCoordinator
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let homeViewController = HomeViewController(coordinator: self)
        navigationController.pushViewController(homeViewController, animated: true)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) { }

    func userLoggedOut() {
        parentCoordinator?.childDidLogOut(self)
    }
}
