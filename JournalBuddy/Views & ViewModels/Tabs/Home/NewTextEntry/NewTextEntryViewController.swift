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
    var viewModel: NewTextEntryViewModel
    var cancellables = Set<AnyCancellable>()

    private lazy var saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))

    init(coordinator: HomeCoordinator?, viewModel: NewTextEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

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
        subscribeToPublishers()
    }

    func configure() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = saveButton
        title = "New Text Entry"
    }

    func subscribeToPublishers() {
        viewModel.$savedEntry
            .sink { [weak self] textEntry in
                guard textEntry != nil else { return }

                self?.coordinator?.newTextEntryViewControllerDidCreateEntry()
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {

    }

    @objc func saveButtonTapped() {
        viewModel.saveTextEntry()
    }
}
