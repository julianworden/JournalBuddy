//
//  AddEditVideoEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class AddEditVideoEntryViewController: UIViewController, MainViewController {
    weak var coordinator: AddEditVideoEntryCoordinator?
    var viewModel: AddEditVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: AddEditVideoEntryCoordinator?, viewModel: AddEditVideoEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = AddEditVideoEntryView(viewModel: viewModel)
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
