//
//  EntriesViewTableViewDataSource.swift
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
final class EntriesViewTableViewDataSource: UITableViewDiffableDataSource<EntriesViewTextEntryTableViewSection, TextEntry> {
    let viewModel: EntriesViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: EntriesViewModel, tableView: UITableView) {
        self.viewModel = viewModel

        super.init(tableView: tableView) { tableView, indexPath, textEntry in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDConstants.entriesViewTextEntryCellID) else {
                return UITableViewCell()
            }

            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = textEntry.unixDate.unixDateAsDate.timeOmittedNumericDateString
            contentConfiguration.secondaryText = textEntry.text
            cell.accessoryType = .disclosureIndicator
            cell.contentConfiguration = contentConfiguration

            return cell
        }

        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        viewModel.$textEntries
            .sink { [weak self] textEntries in
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
}
