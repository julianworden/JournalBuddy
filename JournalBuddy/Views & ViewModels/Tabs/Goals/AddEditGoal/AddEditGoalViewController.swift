//
//  AddEditGoalViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Combine
import UIKit

class AddEditGoalViewController: UIViewController, MainViewController {
    private lazy var cancelButton = UIBarButtonItem(
        title: "Cancel",
        style: .plain,
        target: self,
        action: #selector(cancelButtonTapped)
    )
    private lazy var deleteButton = UIBarButtonItem(
        title: "Delete Text Entry",
        image: SFSymbolConstants.trash,
        target: self,
        action: #selector(deleteButtonTapped)
    )
    
    weak var coordinator: GoalsCoordinator?
    let viewModel: AddEditGoalViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(
        viewModel: AddEditGoalViewModel,
        coordinator: GoalsCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
        
        configure()
        subscribeToPublishers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = AddEditGoalView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure() {
        navigationItem.title = viewModel.navigationTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = cancelButton
        
        if viewModel.goalToEdit != nil {
            navigationItem.rightBarButtonItem = deleteButton
        }
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .goalIsSaving, .goalIsUpdating, .goalIsDeleting:
                    self.cancelButton.isEnabled = false
                    self.deleteButton.isEnabled = false
                    self.deleteButton.image = UIImage(
                        systemName: "trash.circle.fill",
                        withConfiguration: .destructiveDisabledColorWithBackground
                    )
                    self.isModalInPresentation = true
                case .goalWasSaved, .goalWasUpdated, .goalWasDeleted:
                    self.coordinator?.dismissAddEditGoalViewController(self)
                case .error(let message):
                    self.showError(message)
                    self.cancelButton.isEnabled = true
                    self.deleteButton.isEnabled = true
                    self.deleteButton.image = SFSymbolConstants.trash
                    self.isModalInPresentation = false
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(
            onViewController: navigationController,
            errorMessage: errorMessage
        )
    }
    
    func deleteGoalConfirmed() {
        guard let goalToEdit = viewModel.goalToEdit else {
            print("❌ Deleting shouldn't be available for new goals.")
            return
        }
        
        Task {
            await viewModel.deleteGoal(goalToEdit)
        }
    }
    
    @objc func cancelButtonTapped() {
        coordinator?.dismissAddEditGoalViewController(self)
    }
    
    @objc func deleteButtonTapped() {
        guard let navigationController else {
            print("❌ The current view is not being presented within a navigation controller.")
            return
        }
        
        AlertPresenter.presentDestructiveConfirmationAlert(
            onViewController: navigationController,
            message: "You are about to permanently delete this goal. This is irreversible.",
            confirmedWork: deleteGoalConfirmed
        )
    }
}
