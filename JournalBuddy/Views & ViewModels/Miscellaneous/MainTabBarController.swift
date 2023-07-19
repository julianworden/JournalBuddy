//
//  MainTabBarController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/18/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    weak var coordinator: TabBarCoordinator?
    lazy var homeCoordinator = HomeCoordinator(navigationController: UINavigationController(), parentCoordinator: coordinator)
    
    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator

        super.init(nibName: nil, bundle: nil)

        viewControllers = [homeCoordinator.navigationController]
        homeCoordinator.start()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}