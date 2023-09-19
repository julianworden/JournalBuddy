//
//  GoalsViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Combine
import UIKit

class GoalsViewController: UIViewController, MainViewController {
    let createGoalImage = UIImage(systemName: "plus.circle.fill", withConfiguration: .largeScale)
    private lazy var createGoalButton = UIBarButtonItem(image: createGoalImage, style: .plain, target: self, action: #selector(createGoalButtonTapped))
    
    weak var coordinator: GoalsCoordinator?
    let viewModel: GoalsViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: GoalsCoordinator?, viewModel: GoalsViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = GoalsView(viewModel: viewModel, delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        subscribeToPublishers()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        Task {
            await viewModel.fetchGoals()
        }
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchedGoals:
                    self?.configureFetchedGoalsUI()
                case .error(let message):
                    self?.showError(message)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(errorMessage: errorMessage)
    }
    
    func configure() {
        navigationItem.title = "Goals"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func configureFetchedGoalsUI() {
        navigationItem.rightBarButtonItem = createGoalButton
    }
    
    @objc func createGoalButtonTapped() {
        coordinator?.presentAddEditGoalViewController(goalToEdit: nil)
    }
}

extension GoalsViewController: GoalsViewDelegate {
    func goalsViewDidSelect(goalToEdit: Goal) {
        coordinator?.presentAddEditGoalViewController(goalToEdit: goalToEdit)
    }
}
