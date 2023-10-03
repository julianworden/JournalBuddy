//
//  GoalsView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Combine
import UIKit

class GoalsView: UIView, MainView {
    enum TableViewType: Int {
        case incomplete = 0
        case complete
    }
    
    private lazy var fetchingGoalsActivityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var goalTypeSelectorStack = UIStackView(arrangedSubviews: [
        incompleteButton,
        completeButton
    ])
    private lazy var completeButton = PrimaryButton(title: "Complete")
    private lazy var incompleteButton = PrimaryButton(title: "Incomplete")
    private lazy var completeGoalsTableView = MainTableView()
    private lazy var incompleteGoalsTableView = MainTableView()
    private lazy var noGoalsFoundView = NoContentFoundView(
        title: "No Goals Found",
        message: "You can use the plus button to create a goal."
    )

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
        backgroundColor = .background
        
        noGoalsFoundView.isHidden = true
        
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
        completeGoalsTableView.tag = TableViewType.complete.rawValue
        
        incompleteGoalsTableView.register(GoalsTableViewCell.self, forCellReuseIdentifier: GoalsTableViewCell.reuseIdentifier)
        incompleteGoalsTableView.dataSource = incompleteGoalsTableViewDataSource
        incompleteGoalsTableView.delegate = self
        incompleteGoalsTableView.estimatedRowHeight = 44
        incompleteGoalsTableView.showsVerticalScrollIndicator = false
        incompleteGoalsTableView.tag = TableViewType.incomplete.rawValue
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        subscribeToViewStateUpdates()
        subscribeToDynamicTypeChangeUpdates()
    }
    
    func constrain() {
        addConstrainedSubviews(
            fetchingGoalsActivityIndicator,
            goalTypeSelectorStack,
            incompleteGoalsTableView,
            completeGoalsTableView,
            noGoalsFoundView
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
            completeGoalsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            noGoalsFoundView.topAnchor.constraint(greaterThanOrEqualTo: goalTypeSelectorStack.bottomAnchor, constant: 12),
            noGoalsFoundView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            noGoalsFoundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            noGoalsFoundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noGoalsFoundView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
            noGoalsFoundView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
        ])
    }
    
    func subscribeToViewStateUpdates() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingGoals:
                    self?.presentFetchingGoalsUI()
                case .fetchedGoals:
                    self?.presentFetchedGoalsUI()
                case .noGoalsFound:
                    self?.presentNoGoalsFoundUI()
                case .noCompleteGoalsFound:
                    if self?.viewModel.currentlyDisplayingGoalType == .complete {
                        self?.presentNoCompleteGoalsFoundUI()
                    } else {
                        self?.presentIncompleteGoalsUI()
                    }
                case .noIncompleteGoalsFound:
                    if self?.viewModel.currentlyDisplayingGoalType == .incomplete {
                        self?.presentNoIncompleteGoalsFoundUI()
                    } else {
                        self?.presentCompleteGoalsUI()
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToDynamicTypeChangeUpdates() {
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] notification in
                let newContentSizeCategory = notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as! UIContentSizeCategory
                self?.adjustLayoutForNewPreferredContentSizeCategory(newContentSizeCategory)
            }
            .store(in: &cancellables)
    }
    
    /// Presents UI elements to show the user that goals are being fetched.
    func presentFetchingGoalsUI() {
        goalTypeSelectorStack.isHidden = true
        completeGoalsTableView.isHidden = true
        incompleteGoalsTableView.isHidden = true
        noGoalsFoundView.isHidden = true
        
        fetchingGoalsActivityIndicator.hidesWhenStopped = true
        fetchingGoalsActivityIndicator.startAnimating()
        fetchingGoalsActivityIndicator.color = .primaryElement
    }
    
    /// Called when both incomplete goals and complete goals have been found.
    func presentFetchedGoalsUI() {
        goalTypeSelectorStack.isHidden = false
        fetchingGoalsActivityIndicator.stopAnimating()
        
        if viewModel.currentlyDisplayingGoalType == .incomplete {
            if viewModel.incompleteGoals.isEmpty {
                presentNoIncompleteGoalsFoundUI()
            } else {
                presentIncompleteGoalsUI()
            }
        } else if viewModel.currentlyDisplayingGoalType == .complete {
            if viewModel.completeGoals.isEmpty {
                presentNoCompleteGoalsFoundUI()
            } else {
                presentCompleteGoalsUI()
            }
        }
    }
    
    /// Presents the user's complete goals.
    func presentCompleteGoalsUI() {
        fetchingGoalsActivityIndicator.stopAnimating()
        goalTypeSelectorStack.isHidden = false
        incompleteGoalsTableView.isHidden = true
        completeGoalsTableView.isHidden = false
        noGoalsFoundView.isHidden = true
        goalTypeSelectorStack.isHidden = false
    }
    
    /// Presents the user's incomplete goals.
    func presentIncompleteGoalsUI() {
        fetchingGoalsActivityIndicator.stopAnimating()
        goalTypeSelectorStack.isHidden = false
        incompleteGoalsTableView.isHidden = false
        completeGoalsTableView.isHidden = true
        noGoalsFoundView.isHidden = true
        goalTypeSelectorStack.isHidden = false
    }
    
    /// Shows the user that no incomplete goals have been found. This method is only called when
    /// complete goals have been found. Otherwise, `presentNoGoalsFoundUI` should be called.
    func presentNoIncompleteGoalsFoundUI() {
        fetchingGoalsActivityIndicator.stopAnimating()
        noGoalsFoundView.updateTitle(to: "No Incomplete Goals Found")
        noGoalsFoundView.updateSubtitle(to: "You can use the plus button to create a goal.")
        noGoalsFoundView.isHidden = false
        completeGoalsTableView.isHidden = true
        incompleteGoalsTableView.isHidden = true
        goalTypeSelectorStack.isHidden = false
    }
    
    /// Shows the user that no complete goals have been found. This method is only called when
    /// incomplete goals have been found. Otherwise, `presentNoGoalsFoundUI` should be called.
    func presentNoCompleteGoalsFoundUI() {
        fetchingGoalsActivityIndicator.stopAnimating()
        noGoalsFoundView.updateTitle(to: "No Complete Goals Found")
        noGoalsFoundView.updateSubtitle(to: "When you complete goals, they will appear here.")
        noGoalsFoundView.isHidden = false
        completeGoalsTableView.isHidden = true
        incompleteGoalsTableView.isHidden = true
        goalTypeSelectorStack.isHidden = false
    }
    
    /// Shows the user that no complete or incomplete goals have been found.
    func presentNoGoalsFoundUI() {
        fetchingGoalsActivityIndicator.stopAnimating()
        noGoalsFoundView.updateTitle(to: "No Goals Found")
        noGoalsFoundView.updateSubtitle(to: "You can use the plus button to create a goal.")
        completeGoalsTableView.isHidden = true
        incompleteGoalsTableView.isHidden = true
        noGoalsFoundView.isHidden = false
        goalTypeSelectorStack.isHidden = true
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
            Task {
                completeGoalsTableView.isHidden = true
                incompleteGoalsTableView.isHidden = false
                viewModel.currentlyDisplayingGoalType = .incomplete
                completeButton.backgroundColor = .disabled
                incompleteButton.backgroundColor = .primaryElement
                
                if !viewModel.goalsQueryWasPerformed {
                    await viewModel.fetchGoals()
                } else if viewModel.viewState == .noIncompleteGoalsFound {
                    presentNoIncompleteGoalsFoundUI()
                } else if viewModel.viewState == .noGoalsFound {
                    presentNoGoalsFoundUI()
                } else if !viewModel.incompleteGoals.isEmpty {
                    presentIncompleteGoalsUI()
                }
            }
        }
    }
    
    @objc func completeButtonTapped() {
        if viewModel.currentlyDisplayingGoalType == .incomplete {
            Task {
                UINotificationFeedbackGenerator().prepare()
                completeGoalsTableView.isHidden = false
                incompleteGoalsTableView.isHidden = true
                viewModel.currentlyDisplayingGoalType = .complete
                incompleteButton.backgroundColor = .disabled
                completeButton.backgroundColor = .primaryElement
                
                if !viewModel.goalsQueryWasPerformed {
                    await viewModel.fetchGoals()
                } else if viewModel.viewState == .noCompleteGoalsFound {
                    presentNoCompleteGoalsFoundUI()
                } else if viewModel.viewState == .noGoalsFound {
                    presentNoGoalsFoundUI()
                } else if viewModel.viewState == .noIncompleteGoalsFound {
                    presentCompleteGoalsUI()
                }
            }
        }
    }
}

extension GoalsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let selectedGoal = getSelectedGoal(in: tableView, at: indexPath) else {
            print("❌ Failed to determine which goal was selected.")
            return
        }
        
        delegate?.goalsViewDidSelect(goalToEdit: selectedGoal)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            Task {
                guard let selectedGoal = self?.getSelectedGoal(in: tableView, at: indexPath) else {
                    print("❌ Failed to determine which goal was selected.")
                    return
                }
                
                await self?.viewModel.deleteGoal(selectedGoal)
            }
        }
        
        action.backgroundColor = .destructive
        action.image = UIImage(systemName: "trash", withConfiguration: .backgroundColor)
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [action])
        return swipeActionsConfiguration
    }
    
    func getSelectedGoal(in tableView: UITableView, at indexPath: IndexPath) -> Goal? {
        switch tableView.tag {
        case TableViewType.incomplete.rawValue:
            return self.viewModel.incompleteGoals[indexPath.row]
        case TableViewType.complete.rawValue:
            return self.viewModel.completeGoals[indexPath.row]
        default:
            print("❌ Delete received unknown table view tag: \(tableView.tag).")
            return nil
        }
    }
}
