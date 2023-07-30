//
//  HomeCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

@MainActor
final class HomeCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: TabBarCoordinator?
    ) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        self.databaseService = databaseService
        self.authService = authService
        self.parentCoordinator = parentCoordinator

        super.init()

        self.navigationController.delegate = self
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let homeViewModel = HomeViewModel(
            databaseService: databaseService,
            authService: authService
        )

        let homeViewController = HomeViewController(coordinator: self, viewModel: homeViewModel)
        navigationController.pushViewController(homeViewController, animated: true)
    }

    func presentNewTextEntryViewController() {
        let addEditTextEntryCoordinator = AddEditTextEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            textEntryToEdit: nil
        )
        childCoordinators.append(addEditTextEntryCoordinator)

        addEditTextEntryCoordinator.start()
    }

    func userLoggedOut() {
        parentCoordinator?.childDidLogOut(self)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
            }
        }
    }

    func viewController(_ viewController: UIViewController, shouldPresentErrorMessage message: String) {
        AlertPresenter.presentBasicErrorAlert(on: viewController, errorMessage: message)
    }
}

extension HomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }

        if navigationController.viewControllers.contains(fromViewController) { return }

        if let addEditTextEntryViewController = fromViewController as? AddEditTextEntryViewController {
            removeChildCoordinator(addEditTextEntryViewController.coordinator)
        }
    }
}
