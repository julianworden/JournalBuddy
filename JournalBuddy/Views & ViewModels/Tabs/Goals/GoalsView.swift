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
    }
    
    func constrain() {
        addConstrainedSubviews(fetchingGoalsActivityIndicator, goalsTableView)

        NSLayoutConstraint.activate([
            fetchingGoalsActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingGoalsActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            goalsTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            goalsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            goalsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            goalsTableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configureFetchingGoalsUI() {
        backgroundColor = .background
        
        goalsTableView.isHidden = true
        
        fetchingGoalsActivityIndicator.hidesWhenStopped = true
        fetchingGoalsActivityIndicator.startAnimating()
        fetchingGoalsActivityIndicator.color = .primaryElement
    }
    
    func configureFetchedGoalsUI() {
        goalsTableView.register(GoalsTableViewCell.self, forCellReuseIdentifier: GoalsTableViewCell.reuseIdentifier)
        goalsTableView.dataSource = goalsTableViewDataSource
        goalsTableView.delegate = self
        goalsTableView.estimatedRowHeight = 44
        goalsTableView.isHidden = false
    }
}

extension GoalsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.goalsViewDidSelect(goalToEdit: viewModel.goals[indexPath.row])
    }
}
