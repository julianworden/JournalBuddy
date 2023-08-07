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
    let authService: AuthServiceProtocol
    let currentUser: User
    lazy var homeCoordinator = HomeCoordinator(
        navigationController: MainNavigationController(),
        databaseService: databaseService,
        authService: authService,
        parentCoordinator: coordinator,
        currentUser: currentUser
    )
    lazy var entriesCoordinator = EntriesCoordinator(
        navigationController: MainNavigationController(),
        databaseService: databaseService,
        authService: authService,
        parentCoordinator: coordinator,
        currentUser: currentUser
    )

    init(
        coordinator: TabBarCoordinator,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        currentUser: User
    ) {
        self.coordinator = coordinator
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        viewControllers = [homeCoordinator.navigationController, entriesCoordinator.navigationController]

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .background
        tabBarAppearance.shadowColor = nil
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.disabled]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .disabled

        tabBar.barTintColor = .background
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance

        homeCoordinator.start()
        entriesCoordinator.start()
    }
}
