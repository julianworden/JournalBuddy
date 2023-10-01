//
//  TextEntryTableViewDataSource.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/27/23.
//

import Combine
import UIKit

enum EntriesViewTextEntryTableViewSection {
    case main
}

@MainActor
final class TextEntryTableViewDataSource: UITableViewDiffableDataSource<EntriesViewTextEntryTableViewSection, TextEntry> {
    /// Checked by the parent view controller while it's appearing to determine if the table view needs updates. This is set to true when new
    /// text entries are fetched while the table view is off screen. When it is true, the parent view controller will call `updateDataSource(with:)`
    /// while appearing. After the update occurs, this is set to false again.
    var tableViewNeedsUpdate = false
    /// When updating is attempted while the table view is off screen, the full array of the user's
    /// text entries is held in this property so that the parent view controller
    /// can update the table view next time it appears. After the update occurs, the array becomes
    /// empty again.
    var updatedTextEntries = [TextEntry]()
    
    let viewModel: EntriesViewModel
    let tableView: UITableView
    var cancellables = Set<AnyCancellable>()

    init(viewModel: EntriesViewModel, tableView: UITableView) {
        self.viewModel = viewModel
        self.tableView = tableView

        super.init(tableView: tableView) { tableView, indexPath, textEntry in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextEntryTableViewCell.reuseID) as? TextEntryTableViewCell else {
                return UITableViewCell()
            }

            cell.configure(with: textEntry)
            return cell
        }

        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        viewModel.$textEntries
            .sink { [weak self] textEntries in
                // Prevent table view from being updated while it's off screen to avoid warning in console
                guard self?.tableView.window != nil else {
                    self?.tableViewNeedsUpdate = true
                    self?.updatedTextEntries = textEntries
                    return
                }
                
                self?.updateDataSource(with: textEntries)
            }
            .store(in: &cancellables)
    }

    func updateDataSource(with textEntries: [TextEntry]) {
        var snapshot = NSDiffableDataSourceSnapshot<EntriesViewTextEntryTableViewSection, TextEntry>()

        snapshot.appendSections([EntriesViewTextEntryTableViewSection.main])
        snapshot.appendItems(textEntries)

        apply(snapshot)
    }
    
    func updateDataSourceIfNeeded() {
        guard tableViewNeedsUpdate else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<EntriesViewTextEntryTableViewSection, TextEntry>()

        snapshot.appendSections([EntriesViewTextEntryTableViewSection.main])
        snapshot.appendItems(updatedTextEntries)

        apply(snapshot)
        
        tableViewNeedsUpdate = false
        updatedTextEntries = []
    }
}
