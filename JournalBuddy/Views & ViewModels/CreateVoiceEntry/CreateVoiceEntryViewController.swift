//
//  CreateVoiceEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Combine
import UIKit

class CreateVoiceEntryViewController: UIViewController, MainViewController {
    private lazy var stopButton = UIBarButtonItem(image: UIImage(systemName: "stop"), style: .plain, target: self, action: #selector(stopButtonTapped))
    private lazy var playButton = UIBarButtonItem(image: UIImage(systemName: "play"), style: .plain, target: self, action: #selector(playButtonTapped))
    
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
        navigationItem.rightBarButtonItems = [playButton, stopButton]
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
    
    @objc func playButtonTapped() {
        viewModel.startPlaying()
    }
    
    @objc func stopButtonTapped() {
        viewModel.stopRecording()
    }
}
