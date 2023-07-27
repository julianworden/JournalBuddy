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

    func disableSaveButton() {
        saveButton.isEnabled = false
    }

    func enableSaveButton() {
        saveButton.isEnabled = true
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .savingTextEntry:
                    self?.disableSaveButton()
                case .textEntrySaved:
                    self?.coordinator?.newTextEntryViewControllerDidCreateEntry()
                case .error(let errorMessage):
                    self?.enableSaveButton()
                    self?.showError(errorMessage)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ errorMessage: String) {
        self.coordinator?.viewController(self, shouldPresentErrorMessage: errorMessage)
    }

    @objc func saveButtonTapped() {
        Task {
            await viewModel.saveTextEntry()
        }
    }
}
