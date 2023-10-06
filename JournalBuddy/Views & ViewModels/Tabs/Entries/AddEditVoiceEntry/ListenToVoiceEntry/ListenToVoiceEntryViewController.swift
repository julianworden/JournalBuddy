//
//  ListenToVoiceEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/27/23.
//

import Combine
import UIKit

class ListenToVoiceEntryViewController: UIViewController, MainViewController {
    private lazy var deleteButton = UIBarButtonItem(
        image: SFSymbolConstants.trash,
        style: .plain,
        target: self,
        action: #selector(deleteButtonTapped)
    )
    
    weak var coordinator: VoiceEntryCoordinator?
    let viewModel: ListenToVoiceEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(coordinator: VoiceEntryCoordinator?, viewModel: ListenToVoiceEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = ListenToVoiceEntryView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        subscribeToPublishers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.cleanUp()
    }
    
    func configure() {
        navigationItem.title = viewModel.voiceEntry.unixDateCreated.unixDateAsDate.timeOmittedNumericDateString
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchedVoiceEntry:
                    self?.navigationItem.rightBarButtonItem = self?.deleteButton
                case .deletingVoiceEntry:
                    self?.disableButton()
                case .deletedVoiceEntry:
                    self?.coordinator?.dismissListenToVoiceEntryViewController()
                case .error(let message):
                    self?.showError(message)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(errorMessage: errorMessage)
    }
    
    func disableButton() {
        deleteButton.isEnabled = false
        deleteButton.image = UIImage(
            systemName: "trash.circle.fill",
            withConfiguration: .destructiveDisabledColorWithBackground
        )
    }
    
    @objc func deleteButtonTapped() {
        AlertPresenter.presentDestructiveConfirmationAlert(
            message: "You are about to delete this video entry. This is irreversible.",
            confirmedWork: viewModel.deleteVoiceEntry
        )
    }
}
