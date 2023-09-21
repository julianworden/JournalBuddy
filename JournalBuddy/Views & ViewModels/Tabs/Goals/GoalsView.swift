//
//  GoalsView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Combine
import UIKit

class GoalsView: UIView, MainView {
    private lazy var fetchingGoalsActivityIndicator = UIActivityIndicatorView(style: .large)
    private lazy var goalTypeSelectorStack = UIStackView(arrangedSubviews: [
        incompleteButton,
        completeButton
    ])
    private lazy var completeButton = PrimaryButton(title: "Complete")
    private lazy var incompleteButton = PrimaryButton(title: "Incomplete")
    private lazy var completeGoalsTableView = MainTableView()
    private lazy var incompleteGoalsTableView = MainTableView()

    private lazy var completeGoalsTableViewDataSource = CompleteGoalsTableViewDataSource(
        viewModel: viewModel,
        tableView: completeGoalsTableView
    )
    private lazy var incompleteGoalsTableViewDataSource = IncompleteGoalsTableViewDataSource(
        viewModel: viewModel,
        tableView: incompleteGoalsTableView
    )
    
    weak var delegate: GoalsViewDelegate?
    let viewModel: GoalsViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: GoalsViewModel, delegate: GoalsViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate

        super.init(frame: .zero)

        configure()
        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        goalTypeSelectorStack.spacing = 12
        if UIApplication.shared.preferredContentSizeCategory >= .accessibilityExtraLarge {
            goalTypeSelectorStack.axis = .vertical
        }
        
        incompleteButton.titleLabel?.numberOfLines = 1
        incompleteButton.addTarget(self, action: #selector(incompleteButtonTapped), for: .touchUpInside)
        
        completeButton.titleLabel?.numberOfLines = 1
        completeButton.backgroundColor = .disabled
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        completeGoalsTableView.register(GoalsTableViewCell.self, forCellReuseIdentifier: GoalsTableViewCell.reuseIdentifier)
        completeGoalsTableView.dataSource = completeGoalsTableViewDataSource
        completeGoalsTableView.delegate = self
        completeGoalsTableView.estimatedRowHeight = 44
        completeGoalsTableView.showsVerticalScrollIndicator = false
        
        incompleteGoalsTableView.register(GoalsTableViewCell.self, forCellReuseIdentifier: GoalsTableViewCell.reuseIdentifier)
        incompleteGoalsTableView.dataSource = incompleteGoalsTableViewDataSource
        incompleteGoalsTableView.delegate = self
        incompleteGoalsTableView.estimatedRowHeight = 44
        incompleteGoalsTableView.showsVerticalScrollIndicator = false
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingGoals:
                    self?.configureFetchingGoalsUI()
                case .fetchedGoals:
                    self?.configureFetchedGoalsUI()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] notification in
                let newContentSizeCategory = notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as! UIContentSizeCategory
                self?.adjustLayoutForNewPreferredContentSizeCategory(newContentSizeCategory)
            }
            .store(in: &cancellables)
    }
    
    func constrain() {
        addConstrainedSubviews(
            fetchingGoalsActivityIndicator,
            goalTypeSelectorStack,
            incompleteGoalsTableView,
            completeGoalsTableView
        )

        NSLayoutConstraint.activate([
            fetchingGoalsActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingGoalsActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            goalTypeSelectorStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            goalTypeSelectorStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            goalTypeSelectorStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
            goalTypeSelectorStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            
            incompleteButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            incompleteButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            completeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            completeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            
            incompleteGoalsTableView.topAnchor.constraint(equalTo: goalTypeSelectorStack.bottomAnchor, constant: 5),
            incompleteGoalsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            incompleteGoalsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            incompleteGoalsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            completeGoalsTableView.topAnchor.constraint(equalTo: goalTypeSelectorStack.bottomAnchor, constant: 5),
            completeGoalsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            completeGoalsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            completeGoalsTableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configureFetchingGoalsUI() {
        backgroundColor = .background
        
        goalTypeSelectorStack.isHidden = true
        completeGoalsTableView.isHidden = true
        incompleteGoalsTableView.isHidden = true
        
        fetchingGoalsActivityIndicator.hidesWhenStopped = true
        fetchingGoalsActivityIndicator.startAnimating()
        fetchingGoalsActivityIndicator.color = .primaryElement
    }
    
    func configureFetchedGoalsUI() {
        goalTypeSelectorStack.isHidden = false
        incompleteGoalsTableView.isHidden = false
    }
    
    func adjustLayoutForNewPreferredContentSizeCategory(_ newContentSizeCategory: UIContentSizeCategory) {
        if newContentSizeCategory >= .accessibilityExtraLarge {
            goalTypeSelectorStack.axis = .vertical
        } else {
            goalTypeSelectorStack.axis = .horizontal
        }
    }
    
    @objc func incompleteButtonTapped() {
        if viewModel.currentlyDisplayingGoalType == .complete {
            completeGoalsTableView.isHidden = true
            incompleteGoalsTableView.isHidden = false
            viewModel.currentlyDisplayingGoalType = .incomplete
            completeButton.backgroundColor = .disabled
            incompleteButton.backgroundColor = .primaryElement
            incompleteGoalsTableViewDataSource.updateDataSource(with: viewModel.incompleteGoals)
        }
    }
    
    @objc func completeButtonTapped() {
        if viewModel.currentlyDisplayingGoalType == .incomplete {
            UINotificationFeedbackGenerator().prepare()
            completeGoalsTableView.isHidden = false
            incompleteGoalsTableView.isHidden = true
            viewModel.currentlyDisplayingGoalType = .complete
            incompleteButton.backgroundColor = .disabled
            completeButton.backgroundColor = .primaryElement
            completeGoalsTableViewDataSource.updateDataSource(with: viewModel.completeGoals)
        }
    }
}

extension GoalsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedGoal = switch viewModel.currentlyDisplayingGoalType {
        case .complete:
            viewModel.completeGoals[indexPath.row]
        case .incomplete:
            viewModel.incompleteGoals[indexPath.row]
        }
        
        delegate?.goalsViewDidSelect(goalToEdit: selectedGoal)
    }
}
