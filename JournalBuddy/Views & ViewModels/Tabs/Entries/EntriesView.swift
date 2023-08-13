//
//  EntriesView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class EntriesView: UIView, MainView {
    private lazy var tableView = MainTableView()
    private lazy var tableViewDataSource = EntriesViewTableViewDataSource(
        viewModel: viewModel,
        tableView: tableView
    )
    private lazy var fetchingEntriesActivityIndicator = UIActivityIndicatorView(style: .medium)

    let viewModel: EntriesViewModel
    weak var delegate: EntriesViewDelegate?
    var cancellables = Set<AnyCancellable>()

    init(viewModel: EntriesViewModel, delegate: EntriesViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate

        super.init(frame: .zero)

        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureFetchingEntriesUI() {
        backgroundColor = .background

        tableView.isHidden = true

        fetchingEntriesActivityIndicator.hidesWhenStopped = true
        fetchingEntriesActivityIndicator.startAnimating()
    }

    func configureTableView() {
        tableView.register(
            EntriesViewTableViewCell.self,
            forCellReuseIdentifier: EntriesViewTableViewCell.reuseID
        )
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
    }

    func configureFetchedEntriesUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        tableView.isHidden = false
    }

    func constrain() {
        addConstrainedSubviews(tableView, fetchingEntriesActivityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            fetchingEntriesActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingEntriesActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingEntries:
                    self?.configureFetchingEntriesUI()
                case .fetchedEntries:
                    self?.configureTableView()
                    self?.configureFetchedEntriesUI()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

extension EntriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let tappedEntry = viewModel.textEntries[indexPath.row]
        delegate?.entriesViewDidSelectTextEntry(tappedEntry)
    }
}
