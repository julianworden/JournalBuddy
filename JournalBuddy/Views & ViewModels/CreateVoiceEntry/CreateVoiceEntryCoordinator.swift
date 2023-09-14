//
//  CreateVoiceEntryCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import UIKit

@MainActor
final class CreateVoiceEntryCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let navigationController: MainNavigationController
    let currentUser: User
    
    init(
        parentCoordinator: Coordinator,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        navigationController: MainNavigationController,
        currentUser: User
    ) {
        self.parentCoordinator = parentCoordinator
        self.databaseService = databaseService
        self.authService = authService
        self.navigationController = navigationController
        self.currentUser = currentUser
    }
    
    func start() {
        let createVoiceEntryViewModel = CreateVoiceEntryViewModel(
            databaseService: databaseService,
            authService: authService,
            currentUser: currentUser
        )
        
        let createVoiceEntryViewController = CreateVoiceEntryViewController(coordinator: self, viewModel: createVoiceEntryViewModel)
        navigationController.pushViewController(createVoiceEntryViewController, animated: true)
    }
    
    func removeChildCoordinator(_ childCoordinator: Coordinator?) {
        
    }
    
    func viewControllerShouldPresentErrorMessage(_ errorMessage: String) {
        
    }
    
    func presentMicInadequatePermissionsAlert(on viewController: UIViewController) {
        AlertPresenter.presentInadequatePermissionsAlert(
            on: viewController,
            withMessage: "Before you can create a voice entry, you'll need to grant us permission to access your microphone in Settings."
        )
    }
}
