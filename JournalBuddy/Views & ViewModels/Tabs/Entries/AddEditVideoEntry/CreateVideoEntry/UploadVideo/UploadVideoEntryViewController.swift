//
//  UploadVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import UIKit

class UploadVideoEntryViewController: UIViewController, MainViewController {
    private lazy var backButton = BackButton(configuration: .back)
    
    weak var coordinator: CreateVideoEntryCoordinator?
    let viewModel: UploadVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: CreateVideoEntryCoordinator?, viewModel: UploadVideoEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UploadVideoEntryView(viewModel: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        subscribeToPublishers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let view = view as? UploadVideoEntryView else {
            print("❌ Incorrect view set for UploadVideoEntryViewController.")
            return
        }
        
        view.videoPlayerView.deactivateAudioSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        guard let view = view as? UploadVideoEntryView else {
            print("❌ Incorrect view set for UploadVideoEntryViewController.")
            return
        }
        
        if let videoPlayerPeriodicTimeObserver = view.videoPlayerView.playerPeriodicTimeObserver {
            view.videoPlayerView.player?.removeTimeObserver(videoPlayerPeriodicTimeObserver)
            view.videoPlayerView.playerPeriodicTimeObserver = nil
        }
        
        viewModel.deleteLocalRecording()
    }

    func configure() {
        navigationItem.title = "Upload Video Entry"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .videoEntryIsUploading, .videoEntryIsSavingToDevice:
                    self.backButton.isEnabled = false
                case .videoEntryWasUploaded:
                    self.coordinator?.uploadVideoEntryViewControllerDidUploadVideo()
                case .error(let message):
                    self.showError(message)
                    self.backButton.isEnabled = true
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(errorMessage: errorMessage)    }
    
    @objc func backButtonTapped() {
        if viewModel.videoWasSelectedFromLibrary {
            coordinator?.dismissUploadVideoEntryViewController()
        } else {
            coordinator?.presentUploadVideoViewControllerDismissConfirmation()
        }
    }
}
