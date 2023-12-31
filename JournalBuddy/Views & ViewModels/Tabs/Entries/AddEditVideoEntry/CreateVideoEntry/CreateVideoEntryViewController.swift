//
//  CreateVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class CreateVideoEntryViewController: UIViewController, MainViewController {
    #warning("coordinator being unallocated earlier than expected")
    weak var coordinator: CreateVideoEntryCoordinator?
    var viewModel: CreateVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(coordinator: CreateVideoEntryCoordinator?, viewModel: CreateVideoEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = CreateVideoEntryView(viewModel: viewModel, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        subscribeToPublishers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        guard let view = view as? CreateVideoEntryView else { return }
        
        // In case the user goes back after recording video
        view.setNewRecordingTimerLabelText()
        view.switchCameraButton.alpha = 1
        view.switchCameraButton.isEnabled = true
        view.showVideoPickerButton.alpha = 1
        view.showVideoPickerButton.isEnabled = true
        view.backButton.alpha = 1
        view.backButton.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.deactivateAudioSession()
    }
    
    func configure() {
        navigationController?.isNavigationBarHidden = true
        // Allows the camera view finder to go into the safe area
        viewRespectsSystemMinimumLayoutMargins = false
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .videoEntryWasSelectedOrRecorded(let videoURL, let videoWasSelectedFromLibrary):
                    self.coordinator?.createVideoEntryViewDidFinishRecording(
                        at: videoURL,
                        videoWasSelectedFromLibrary: videoWasSelectedFromLibrary
                    )
                case .inadequatePermissions:
                    self.coordinator?.presentMicOrCameraInadequatePermissionsAlert(on: self)
                case .error(let message):
                    self.showError(message)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(errorMessage: errorMessage)
    }
}

extension CreateVideoEntryViewController: CreateVideoEntryViewDelegate {
    func createVideoEntryViewControllerShouldDismiss() {
        coordinator?.dismissCreateVideoEntryViewController()
    }
    
    func createVideoEntryViewControllerShouldPresentVideoPicker() {
        coordinator?.createVideoEntryViewControllerShouldPresentVideoPicker(self)
    }
}

extension CreateVideoEntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let videoNSURL = info[.mediaURL] as? NSURL else {
            showError(VideoEntryError.videoSelectionFailed.localizedDescription)
            print("❌ Failed to find the URL for the selected video.")
            return
        }
        
        viewModel.userDidSelectRecordedVideo(at: videoNSURL.absoluteURL!)
    }
}
