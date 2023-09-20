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
    private lazy var goalsTableView = MainTableView()

    private lazy var goalsTableViewDataSource = GoalsTableViewDataSource(viewModel: viewModel, tableView: goalsTableView)
    
    weak var delegate: GoalsViewDelegate?
    let viewModel: GoalsViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: GoalsViewModel, delegate: GoalsViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate

        super.init(frame: .zero)

        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        addConstrainedSubviews(fetchingGoalsActivityIndicator, goalTypeSelectorStack, goalsTableView)

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
            
            goalsTableView.topAnchor.constraint(equalTo: goalTypeSelectorStack.bottomAnchor, constant: 5),
            goalsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            goalsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            goalsTableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configureFetchingGoalsUI() {
        backgroundColor = .background
        
        goalTypeSelectorStack.isHidden = true
        goalsTableView.isHidden = true
        
        fetchingGoalsActivityIndicator.hidesWhenStopped = true
        fetchingGoalsActivityIndicator.startAnimating()
        fetchingGoalsActivityIndicator.color = .primaryElement
    }
    
    func configureFetchedGoalsUI() {
        goalTypeSelectorStack.spacing = 12
        goalTypeSelectorStack.isHidden = false
        if UIApplication.shared.preferredContentSizeCategory >= .accessibilityExtraLarge {
            goalTypeSelectorStack.axis = .vertical
        }
        
        incompleteButton.titleLabel?.numberOfLines = 1
        
        completeButton.titleLabel?.numberOfLines = 1
        completeButton.backgroundColor = .disabled
        
        goalsTableView.register(GoalsTableViewCell.self, forCellReuseIdentifier: GoalsTableViewCell.reuseIdentifier)
        goalsTableView.dataSource = goalsTableViewDataSource
        goalsTableView.delegate = self
        goalsTableView.estimatedRowHeight = 44
        goalsTableView.isHidden = false
    }
    
    func adjustLayoutForNewPreferredContentSizeCategory(_ newContentSizeCategory: UIContentSizeCategory) {
        if newContentSizeCategory >= .accessibilityExtraLarge {
            goalTypeSelectorStack.axis = .vertical
        } else {
            goalTypeSelectorStack.axis = .horizontal
        }
    }
}

extension GoalsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.goalsViewDidSelect(goalToEdit: viewModel.goals[indexPath.row])
    }
}
