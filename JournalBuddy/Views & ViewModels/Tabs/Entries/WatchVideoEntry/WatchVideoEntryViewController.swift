//
//  WatchVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/24/23.
//

import Combine
import UIKit

final class WatchVideoEntryViewController: UIViewController, MainViewController {
    weak var coordinator: EntriesCoordinator?
    let viewModel: WatchVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(coordinator: EntriesCoordinator?, viewModel: WatchVideoEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
    }
    
    func subscribeToPublishers() {
        
    }
    
    func showError(_ errorMessage: String) {
        
    }
}
