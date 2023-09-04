//
//  CreateVideoEntryCoordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import AVFoundation
import UIKit

@MainActor
final class CreateVideoEntryCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var databaseService: DatabaseServiceProtocol
    var authService: AuthServiceProtocol
    let navigationController: MainNavigationController
    let currentUser: User

    init(
        parentCoordinator: Coordinator?,
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
        let addEditVideoEntryViewModel = CreateVideoEntryViewModel()
        let addEditVideoEntryViewController = CreateVideoEntryViewController(
            coordinator: self,
            viewModel: addEditVideoEntryViewModel
        )

        navigationController.pushViewController(addEditVideoEntryViewController, animated: true)
    }
    
    func removeChildCoordinator(_ childCoordinator: Coordinator?) { }

    func viewControllerShouldPresentErrorMessage(_ errorMessage: String) {
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }

    func createVideoEntryViewDidFinishRecording(at videoURL: URL) {
        let uploadVideoViewModel = UploadVideoViewModel(recordedVideoURL: videoURL)
        let uploadVideoViewController = UploadVideoViewController(coordinator: self, viewModel: uploadVideoViewModel)

        navigationController.pushViewController(uploadVideoViewController, animated: true)
    }
    
    func dismissCreateVideoEntryViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func presentUploadVideoViewControllerDismissConfirmation() {
        AlertPresenter.presentDestructiveConfirmationAlert(
            message: "If you go back, your video entry will be discarded.",
            confirmedWork: popCurrentViewController
        )
    }
    
    func popCurrentViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func createVideoEntryViewControllerShouldPresentVideoPicker(_ viewController: CreateVideoEntryViewController) {
        let videoPicker = UIImagePickerController()
        videoPicker.delegate = viewController
        videoPicker.sourceType = .photoLibrary
        videoPicker.mediaTypes = [UTType.movie.identifier]
        videoPicker.videoMaximumDuration = 300
        // Allow the user to trim the video to 5 minutes if it's too long.
        videoPicker.allowsEditing = true
        
        navigationController.present(videoPicker, animated: true)
    }
}


