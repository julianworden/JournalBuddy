//
//  CreateVoiceEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Combine
import UIKit

class CreateVoiceEntryViewController: UIViewController, MainViewController {
    weak var coordinator: CreateVoiceEntryCoordinator?
    var viewModel: CreateVoiceEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(coordinator: CreateVoiceEntryCoordinator?, viewModel: CreateVoiceEntryViewModel) {
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
    
    func configure() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Create Voice Entry"
        
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
}
