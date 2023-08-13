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
            contentConfiguration.textProperties.font = UIFontMetrics.avenirNextBoldBody
            contentConfiguration.textProperties.color = .primaryElement
            contentConfiguration.textProperties.numberOfLines = 0
            contentConfiguration.secondaryText = textEntry.text
            contentConfiguration.secondaryTextProperties.font = UIFontMetrics.avenirNextRegularBody
            contentConfiguration.secondaryTextProperties.color = .primaryElement
            contentConfiguration.secondaryTextProperties.numberOfLines = 3
            contentConfiguration.textProperties.adjustsFontForContentSizeCategory = true
            contentConfiguration.secondaryTextProperties.adjustsFontForContentSizeCategory = true
            cell.accessoryView = UIImageView(image: .disclosureIndicator)
            cell.contentConfiguration = contentConfiguration

            let selectedCellBackgroundView = UIView()
            selectedCellBackgroundView.backgroundColor = .groupedBackground
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.backgroundColor = .background

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
