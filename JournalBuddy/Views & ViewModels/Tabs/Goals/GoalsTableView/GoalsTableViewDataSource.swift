//
//  GoalsTableViewDataSource.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Combine
import UIKit

enum GoalsTableViewSection {
    case main
}

@MainActor
final class GoalsTableViewDataSource: UITableViewDiffableDataSource<GoalsTableViewSection, Goal> {
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
        viewModel.$goals
            .sink { [weak self] goals in
                self?.updateDataSource(with: goals)
            }
            .store(in: &cancellables)
    }
    
    func updateDataSource(with goals: [Goal]) {
        var snapshot = NSDiffableDataSourceSnapshot<GoalsTableViewSection, Goal>()
        snapshot.appendSections([.main])
        snapshot.appendItems(goals)
        apply(snapshot)
    }
}
