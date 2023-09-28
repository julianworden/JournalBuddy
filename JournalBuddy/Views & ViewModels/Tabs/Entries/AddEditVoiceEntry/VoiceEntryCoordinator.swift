//
//  VoiceEntryCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import UIKit

@MainActor
final class VoiceEntryCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let navigationController: MainNavigationController
    let currentUser: User
    let viewPurpose: VoiceEntryViewPurpose
    
    init(
        parentCoordinator: Coordinator,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        navigationController: MainNavigationController,
        currentUser: User,
        viewPurpose: VoiceEntryViewPurpose
    ) {
        self.parentCoordinator = parentCoordinator
        self.databaseService = databaseService
        self.authService = authService
        self.navigationController = navigationController
        self.currentUser = currentUser
        self.viewPurpose = viewPurpose
    }
    
    func start() {
        switch viewPurpose {
        case .create:
            pushCreateVoiceEntryViewController()
        case .listen(let voiceEntry):
            pushListenToVoiceEntryViewController(for: voiceEntry)
        }
    }
    
    func removeChildCoordinator(_ childCoordinator: Coordinator?) { }
    
    func presentErrorMessage(
        onViewController viewController: UIViewController? = nil,
        errorMessage: String
    ) {
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }
    
    private func pushCreateVoiceEntryViewController() {
        let createVoiceEntryViewModel = CreateVoiceEntryViewModel(
            databaseService: databaseService,
            authService: authService,
            currentUser: currentUser
        )
        
        let createVoiceEntryViewController = CreateVoiceEntryViewController(coordinator: self, viewModel: createVoiceEntryViewModel)
        navigationController.pushViewController(createVoiceEntryViewController, animated: true)
    }
    
    private func pushListenToVoiceEntryViewController(for voiceEntry: VoiceEntry) {
        let listenToVoiceEntryViewModel = ListenToVoiceEntryViewModel(
            databaseService: databaseService,
            authService: authService,
            voiceEntry: voiceEntry
        )
        
        let listenToVoiceEntryViewController = ListenToVoiceEntryViewController(
            coordinator: self,
            viewModel: listenToVoiceEntryViewModel
        )
        navigationController.pushViewController(listenToVoiceEntryViewController, animated: true)
    }
    
    func dismissCreateVoiceEntryViewController() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChildCoordinator(self)
    }
    
    func dismissListenToVoiceEntryViewController() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChildCoordinator(self)
    }
    
    func presentCreateVoiceEntryViewControllerDismissConfirmation() {
        AlertPresenter.presentDestructiveConfirmationAlert(
            message: "If you go back, your recorded entry will be discarded.",
            confirmedWork: dismissCreateVoiceEntryViewController
        )
    }
    
    func presentMicInadequatePermissionsAlert(on viewController: UIViewController) {
        AlertPresenter.presentInadequatePermissionsAlert(
            on: viewController,
            withMessage: "Before you can create a voice entry, you'll need to grant us permission to access your microphone in Settings."
        )
    }
}
