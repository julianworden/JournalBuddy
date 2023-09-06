//
//  UploadVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import UIKit

class UploadVideoEntryViewController: UIViewController, MainViewController {
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

    override func viewDidDisappear(_ animated: Bool) {
        if let videoPlayerPeriodicTimeObserver = viewModel.videoPlayerPeriodicTimeObserver {
            viewModel.videoPlayer.removeTimeObserver(videoPlayerPeriodicTimeObserver)
            viewModel.videoPlayerPeriodicTimeObserver = nil
        }
    }

    func configure() {
        navigationItem.title = "Upload Video Entry"
        navigationItem.largeTitleDisplayMode = .never
        hidesBottomBarWhenPushed = false
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        let backButtonView = BackButtonView(buttonTarget: self, buttonSelector: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
    }

    @objc func backButtonTapped() {
        coordinator?.presentUploadVideoViewControllerDismissConfirmation()
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .videoEntryWasCreated:
                    self?.coordinator?.uploadVideoEntryViewControllerDidUploadVideo()
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
