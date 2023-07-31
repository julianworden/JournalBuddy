//
//  AddEditTextEntryViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class AddEditTextEntryViewController: UIViewController, MainViewController {
    private lazy var saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))

    weak var coordinator: AddEditTextEntryCoordinator?
    var viewModel: AddEditTextEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: AddEditTextEntryCoordinator?, viewModel: AddEditTextEntryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = AddEditTextEntryView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        subscribeToPublishers()
    }

    func configure() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = saveButton
        title = viewModel.navigationTitle
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
                case .savingTextEntry, .textEntryUpdating:
                    self?.disableSaveButton()
                case .textEntrySaved, .textEntryUpdated:
                    self?.coordinator?.addEditTextEntryViewControllerDidSaveTextEntry()
                case .error(let errorMessage):
                    self?.enableSaveButton()
                    self?.showError(errorMessage)
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.$entryText
            .sink { [weak self] entryText in
                if entryText.isReallyEmpty {
                    self?.saveButton.isHidden = true
                    return
                } 

                if let textEntryToEdit = self?.viewModel.textEntryToEdit {
                    // Show save button if TextEntry text has been edited and the new text is not empty
                    self?.saveButton.isHidden = textEntryToEdit.text == entryText
                } else {
                    self?.saveButton.isHidden = entryText.isReallyEmpty
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
