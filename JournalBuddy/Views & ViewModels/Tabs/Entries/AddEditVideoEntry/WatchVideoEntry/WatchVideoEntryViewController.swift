//
//  WatchVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/24/23.
//

import Combine
import UIKit

final class WatchVideoEntryViewController: UIViewController, MainViewController {
    private lazy var deleteButton = UIBarButtonItem(
        image: SFSymbolConstants.trash,
        style: .plain,
        target: self,
        action: #selector(deleteButtonTapped)
    )
    
    weak var coordinator: EntriesCoordinator?
    let viewModel: WatchVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        subscribeToPublishers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let view = view as? WatchVideoEntryView else {
            print("❌ Incorrect view set for UploadVideoEntryViewController.")
            return
        }
        
        view.videoPlayer.deactivateAudioSession()
    }
    
    init(coordinator: EntriesCoordinator?, viewModel: WatchVideoEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = WatchVideoEntryView(viewModel: viewModel)
    }
    
    func configure() {
        navigationItem.title = viewModel.videoEntry.unixDate.unixDateAsDate.timeOmittedNumericDateString
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchedVideoEntry:
                    self?.navigationItem.rightBarButtonItem = self?.deleteButton
                case .deletingVideoEntry:
                    self?.disableButtons()
                case .deletedVideoEntry:
                    self?.coordinator?.dismissWatchVideoEntryViewController()
                case .error(let message):
                    self?.showError(message)
                    self?.enableButtons()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(errorMessage: errorMessage)
    }
    
    func enableButtons() {
        deleteButton.isEnabled = true
        deleteButton.image = SFSymbolConstants.trash
    }
    
    func disableButtons() {
        deleteButton.isEnabled = false
        deleteButton.image = UIImage(
            systemName: "trash.circle.fill",
            withConfiguration: .destructiveDisabledColorWithBackground
        )
    }
    
    @objc func deleteButtonTapped() {
        AlertPresenter.presentDestructiveConfirmationAlert(
            message: "You are about to delete this video entry. This is irreversible.",
            confirmedWork: viewModel.deleteVideoEntry
        )
    }
}
