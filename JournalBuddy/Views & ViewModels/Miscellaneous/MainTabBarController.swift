//
//  MainTabBarController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    weak var coordinator: TabBarCoordinator?
    let databaseService: DatabaseServiceProtocol
    lazy var homeCoordinator = HomeCoordinator(
        navigationController: UINavigationController(),
        databaseService: databaseService,
        parentCoordinator: coordinator
    )
    lazy var entriesCoordinator = EntriesCoordinator(
        navigationController: UINavigationController(),
        databaseService: databaseService,
        parentCoordinator: coordinator
    )

    init(coordinator: TabBarCoordinator, databaseService: DatabaseServiceProtocol) {
        self.coordinator = coordinator
        self.databaseService = databaseService

        super.init(nibName: nil, bundle: nil)

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configure() {
        viewControllers = [homeCoordinator.navigationController, entriesCoordinator.navigationController]

        homeCoordinator.start()
        entriesCoordinator.start()
    }
}
