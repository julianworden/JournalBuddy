//
//  EntriesCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import UIKit

@MainActor
final class EntriesCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: TabBarCoordinator?
    ) {
        self.navigationController = navigationController
        self.databaseService = databaseService
        self.authService = authService
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "list.bullet"), tag: 1)
        self.parentCoordinator = parentCoordinator

        super.init()

        self.navigationController.delegate = self
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let entriesViewModel = EntriesViewModel(databaseService: databaseService, authService: authService)
        let entriesViewController = EntriesViewController(coordinator: self, viewModel: entriesViewModel)
        navigationController.pushViewController(entriesViewController, animated: true)
    }

    func entriesViewDidSelectTextEntry(_ textEntryToEdit: TextEntry) {
        let addEditTextEntryCoordinator = AddEditTextEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            textEntryToEdit: textEntryToEdit
        )

        childCoordinators.append(addEditTextEntryCoordinator)
        addEditTextEntryCoordinator.start()
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

extension EntriesCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }

        if navigationController.viewControllers.contains(fromViewController) { return }

        if let addEdiTextEntryViewController = fromViewController as? AddEditTextEntryViewController {
            removeChildCoordinator(addEdiTextEntryViewController.coordinator)
        }
    }
}
