//
//  CreateVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class CreateVideoEntryViewController: UIViewController, MainViewController {
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
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        guard let view = view as? CreateVideoEntryView else { return }
        
        // In case someone goes back after recording video
        view.recordingTimerLabel.text = "00:00 / 05:00"
        view.switchCameraButton.alpha = 1
        view.switchCameraButton.isEnabled = true
        view.showVideoPickerButton.alpha = 1
        view.showVideoPickerButton.isEnabled = true
        view.backButton.alpha = 1
        view.backButton.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    func configure() {
        // Allows the camera view finder to go into the safe area
        viewRespectsSystemMinimumLayoutMargins = false
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .videoEntryWasSelectedOrRecorded(let videoURL, let videoWasSelectedFromLibrary):
                    self?.coordinator?.createVideoEntryViewDidFinishRecording(
                        at: videoURL,
                        videoWasSelectedFromLibrary: videoWasSelectedFromLibrary
                    )
                case .error(let message):
                    self?.showError(message)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        coordinator?.viewControllerShouldPresentErrorMessage(errorMessage)
    }
}

extension CreateVideoEntryViewController: CreateVideoEntryViewDelegate {
    func createVideoEntryViewControllerShouldDismiss() {
        coordinator?.dismissCurrentViewController()
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
