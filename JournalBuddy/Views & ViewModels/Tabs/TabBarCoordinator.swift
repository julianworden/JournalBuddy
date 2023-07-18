//
//  TabBarCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?
    weak var appWindow: UIWindow?
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController, parentCoordinator: MainCoordinator, appWindow: UIWindow?) {
        self.appWindow = appWindow
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }

    func start() {
        let tabBarController = MainTabBarController(coordinator: self)
        tabBarController.homeCoordinator.start()
        tabBarController.viewControllers = [tabBarController.homeCoordinator.navigationController]
        appWindow?.rootViewController = tabBarController
        appWindow?.makeKeyAndVisible()
    }
}
