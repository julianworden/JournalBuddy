//
//  UploadVideoViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import UIKit

class UploadVideoViewController: UIViewController, MainViewController {
    weak var coordinator: CreateVideoEntryCoordinator?
    let viewModel: UploadVideoViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: CreateVideoEntryCoordinator?, viewModel: UploadVideoViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UploadVideoView(viewModel: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
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
    }

    func subscribeToPublishers() {

    }

    func showError(_ errorMessage: String) {
        coordinator?.viewController(self, shouldPresentErrorMessage: errorMessage)
    }
}
