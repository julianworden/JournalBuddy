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
        view = CreateVideoEntryView(viewModel: viewModel, delegate: coordinator)
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
                case .videoRecordingCompleted(let videoURL):
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
