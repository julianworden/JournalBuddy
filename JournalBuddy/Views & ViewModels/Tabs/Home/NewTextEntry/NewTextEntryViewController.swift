//
//  NewTextEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class NewTextEntryViewController: UIViewController, MainViewController {
    weak var coordinator: HomeCoordinator?
    var viewModel = NewTextEntryViewModel()
    var cancellables = Set<AnyCancellable>()

    init(coordinator: HomeCoordinator?) {
        self.coordinator = coordinator

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NewTextEntryView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        navigationItem.largeTitleDisplayMode = .never
        title = "New Text Entry"
    }

    func subscribeToPublishers() {

    }

    func showError(_ error: Error) {

    }
}
