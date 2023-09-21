//
//  CompleteGoalsTableViewDataSource.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Combine
import UIKit

enum CompleteGoalsTableViewSection {
    case main
}

@MainActor
final class CompleteGoalsTableViewDataSource: UITableViewDiffableDataSource<CompleteGoalsTableViewSection, Goal> {
    let viewModel: GoalsViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: GoalsViewModel, tableView: UITableView) {
        self.viewModel = viewModel
        
        super.init(tableView: tableView) { tableView, indexPath, goal in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GoalsTableViewCell.reuseIdentifier) as? GoalsTableViewCell else {
                return UITableViewCell()
            }
            
            cell.viewModel = viewModel
            cell.configure(with: goal)
            return cell
        }
        
        subscribeToPublishers()
    }
    
    func subscribeToPublishers() {
        viewModel.$completeGoals
            .sink { [weak self] completeGoals in
                if self?.viewModel.currentlyDisplayingGoalType == .complete {
                    self?.updateDataSource(with: completeGoals)
                }
            }
            .store(in: &cancellables)
    }
    
    func updateDataSource(with goals: [Goal]) {
        var snapshot = NSDiffableDataSourceSnapshot<CompleteGoalsTableViewSection, Goal>()
        snapshot.appendSections([.main])
        snapshot.appendItems(goals)
        apply(snapshot)
    }
}
