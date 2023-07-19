//
//  TabBarCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import UIKit

/// A Coordinator that manages hiding and showing the `UITabBarController` that appears either when the user opens the app while already
/// being signed in, or when the user logs in.
final class TabBarCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?
    weak var appWindow: UIWindow?
    var childCoordinators = [Coordinator]()

    init(parentCoordinator: MainCoordinator, appWindow: UIWindow?) {
        self.appWindow = appWindow
        self.parentCoordinator = parentCoordinator
    }

    func start() {
        let tabBarController = MainTabBarController(coordinator: self)
        
        appWindow?.rootViewController = tabBarController
        appWindow?.makeKeyAndVisible()

        if let appWindow {
            UIView.transition(with: appWindow, duration: 0.5, options: .transitionCurlUp, animations: nil)
        }
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
            }
        }
    }

    /// Called by each `UITabBarItem` to notify the parent that a new item's coordinator was created.
    /// - Parameter coordinator: The coordinator that was created and is to be appended to the `childCoordinators` array.
    func childWasCreated(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func childDidLogOut(_ childCoordinator: Coordinator) {
        removeChildCoordinator(childCoordinator)
        parentCoordinator?.childTabBarCoordinatorDidFinish(self)
    }
}
