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
    let navigationController: MainNavigationController
    let currentUser: User

    init(
        navigationController: MainNavigationController,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        parentCoordinator: TabBarCoordinator?,
        currentUser: User
    ) {
        self.navigationController = navigationController
        self.databaseService = databaseService
        self.authService = authService
        let tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "book.circle.fill", withConfiguration: .largeScale), tag: 1)
        self.navigationController.tabBarItem = tabBarItem
        self.parentCoordinator = parentCoordinator
        self.currentUser = currentUser

        super.init()

        self.navigationController.delegate = self
        self.parentCoordinator?.childWasCreated(self)
    }

    func start() {
        let entriesViewModel = EntriesViewModel(
            databaseService: databaseService,
            authService: authService,
            currentUser: currentUser
        )
        let entriesViewController = EntriesViewController(coordinator: self, viewModel: entriesViewModel)
        navigationController.pushViewController(entriesViewController, animated: true)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
            }
        }
    }

    func presentErrorMessage(
        onViewController viewController: UIViewController? = nil,
        errorMessage: String
    ) {
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }
    
    // MARK: - VideoEntry

    func presentAddEditTextEntryViewController(withTextEntryToEdit textEntryToEdit: TextEntry?) {
        let addEditTextEntryCoordinator = AddEditTextEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            currentUser: currentUser,
            textEntryToEdit: textEntryToEdit
        )

        childCoordinators.append(addEditTextEntryCoordinator)
        addEditTextEntryCoordinator.start()
    }

    func presentCreateVideoEntryViewController() {
        let createVideoEntryCoordinator = CreateVideoEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            currentUser: currentUser
        )

        childCoordinators.append(createVideoEntryCoordinator)
        createVideoEntryCoordinator.start()
    }
    
    func presentWatchVideoEntryViewController(withVideoEntry videoEntry: VideoEntry) {
        let watchVideoEntryViewModel = WatchVideoEntryViewModel(
            databaseService: databaseService,
            authService: authService,
            videoEntry: videoEntry
        )
        let watchVideoEntryViewController = WatchVideoEntryViewController(
            coordinator: self,
            viewModel: watchVideoEntryViewModel
        )
        
        navigationController.pushViewController(watchVideoEntryViewController, animated: true)
    }
    
    func dismissWatchVideoEntryViewController() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - VoiceEntry
    
    func presentCreateVoiceEntryViewController() {
        let voiceEntryCoordinator = VoiceEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            currentUser: currentUser,
            viewPurpose: .create
        )
        
        childCoordinators.append(voiceEntryCoordinator)
        voiceEntryCoordinator.start()
    }
    
    func presentListenToVoiceEntryViewController(for voiceEntry: VoiceEntry) {
        let voiceEntryCoordinator = VoiceEntryCoordinator(
            parentCoordinator: self,
            databaseService: databaseService,
            authService: authService,
            navigationController: navigationController,
            currentUser: currentUser,
            viewPurpose: .listen(to: voiceEntry)
        )
        
        childCoordinators.append(voiceEntryCoordinator)
        voiceEntryCoordinator.start()
    }
}

extension EntriesCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }

        if navigationController.viewControllers.contains(fromViewController) { return }

        if let addEditTextEntryViewController = fromViewController as? AddEditTextEntryViewController {
            removeChildCoordinator(addEditTextEntryViewController.coordinator)
        } else if let createVideoEntryViewController = fromViewController as? CreateVideoEntryViewController {
            removeChildCoordinator(createVideoEntryViewController.coordinator)
        } else if let createVoiceEntryViewController = fromViewController as? CreateVoiceEntryViewController {
            removeChildCoordinator(createVoiceEntryViewController.coordinator)
        }
    }
}
