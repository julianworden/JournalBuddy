//
//  CreateVoiceEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Combine
import UIKit

class CreateVoiceEntryViewController: UIViewController, MainViewController {
    private lazy var backButton = BackButton(configuration: .back)
    
    weak var coordinator: VoiceEntryCoordinator?
    var viewModel: CreateVoiceEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(coordinator: VoiceEntryCoordinator?, viewModel: CreateVoiceEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = CreateVoiceEntryView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        subscribeToPublishers()
        viewModel.configureAudioSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if viewModel.voiceEntryHasBeenRecorded {
            viewModel.deleteLocalRecording()
        }
    }
    
    func configure() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Create Voice Entry"
        navigationItem.hidesBackButton = true
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        guard let view = view as? CreateVoiceEntryView else {
            print("❌ CreateVoiceEntryViewController's view should be of type CreateVoiceEntryView.")
            return
        }
        
        view.setNewRecordingTimerLabelText()
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .inadequatePermissions:
                    self.coordinator?.presentMicInadequatePermissionsAlert(on: self)
                case .uploadedVoiceEntry:
                    self.coordinator?.dismissCreateVoiceEntryViewController()
                case .error(let message):
                    self.showError(message)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        AlertPresenter.presentBasicErrorAlert(errorMessage: errorMessage)
    }
    
    @objc func backButtonTapped() {
        if viewModel.voiceEntryHasBeenRecorded {
            coordinator?.presentCreateVoiceEntryViewControllerDismissConfirmation()
        } else {
            coordinator?.dismissCreateVoiceEntryViewController()
        }
    }
}
