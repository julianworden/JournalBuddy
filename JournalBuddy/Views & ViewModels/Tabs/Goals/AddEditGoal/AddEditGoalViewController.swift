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
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .goalIsSaving, .goalIsUpdating:
                    self.cancelButton.isEnabled = false
                    self.isModalInPresentation = true
                case .goalWasSaved, .goalWasUpdated:
                    self.coordinator?.dismissAddEditGoalViewController(self)
                case .error(let message):
                    self.showError(message)
                    self.cancelButton.isEnabled = true
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
    
    @objc func cancelButtonTapped() {
        coordinator?.dismissAddEditGoalViewController(self)
    }
}
