//
//  CreateVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class CreateVideoEntryViewController: UIViewController, MainViewController {
    weak var coordinator: CreateVideoEntryCoordinator?
    var viewModel: CreateVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: CreateVideoEntryCoordinator?, viewModel: CreateVideoEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = CreateVideoEntryView(viewModel: viewModel, delegate: coordinator)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func configure() {
        viewRespectsSystemMinimumLayoutMargins = false
        navigationController?.isNavigationBarHidden = true
    }

    func subscribeToPublishers() {

    }

    func showError(_ errorMessage: String) {
        coordinator?.viewController(self, shouldPresentErrorMessage: errorMessage)
    }
}
