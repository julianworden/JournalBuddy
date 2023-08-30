//
//  CreateVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import PhotosUI
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
    }
    
    func configure() {
        viewRespectsSystemMinimumLayoutMargins = false
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .videoEntryWasSelectedOrRecorded(let videoURL):
                    self?.coordinator?.createVideoEntryViewDidFinishRecording(at: videoURL)
                case .error(let message):
                    self?.showError(message)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        coordinator?.viewController(self, shouldPresentErrorMessage: errorMessage)
    }
}

extension CreateVideoEntryViewController: CreateVideoEntryViewDelegate {
    func createVideoEntryViewControllerShouldDismiss() {
        coordinator?.createVideoEntryViewControllerShouldDismiss()
    }
    
    func createVideoEntryViewControllerShouldPresentVideoPicker() {
        coordinator?.createVideoEntryViewControllerShouldPresentVideoPicker(self)
    }
}

extension CreateVideoEntryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard results.count <= 1 else {
            showError(VideoEntryError.moreThanOneVideoEntryWasSelected.localizedDescription)
            print("The user selected more than 1 video in the video picker.")
            return
        }
        
        guard let selectedVideoResult = results.first else { /* User cancelled video picking */ return }
        
        viewModel.userDidSelectRecordedVideo(selectedVideoResult)
    }
}
