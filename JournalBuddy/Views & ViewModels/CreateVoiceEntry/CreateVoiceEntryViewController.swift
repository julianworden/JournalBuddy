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
    }
    
    func configure() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Create Voice Entry"
    }
    
    func subscribeToPublishers() {
        
    }
    
    func showError(_ errorMessage: String) {
        
    }
}
