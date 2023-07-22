//
//  EntriesCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import UIKit

final class EntriesCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    var databaseService: DatabaseServiceProtocol
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        databaseService: DatabaseServiceProtocol,
        parentCoordinator: TabBarCoordinator?
    ) {
        self.navigationController = navigationController
        self.databaseService = databaseService
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "list.bullet"), tag: 1)
        self.parentCoordinator = parentCoordinator
    }

    func start() {
        let entriesViewController = EntriesViewController(coordinator: self)
        navigationController.pushViewController(entriesViewController, animated: true)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) { }
}
