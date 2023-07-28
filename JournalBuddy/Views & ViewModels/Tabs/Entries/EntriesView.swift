//
//  EntriesView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class EntriesView: UIView, MainView {
    private lazy var tableView = UITableView()
    private lazy var tableViewDataSource = EntriesViewTableViewDataSource(
        viewModel: viewModel,
        tableView: tableView
    )
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)

    let viewModel: EntriesViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: EntriesViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fetchTextEntries() {
        Task {
            await viewModel.fetchTextEntries()
        }
    }

    func configureLoadingUI() {
        backgroundColor = .systemBackground

        tableView.isHidden = true
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }

    func configureTableView() {
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: ReuseIDConstants.entriesViewTextEntryCellID
        )
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
    }

    func configureLoadedUI() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
    }

    func constrain() {
        addConstrainedSubviews(tableView, activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingEntries:
                    self?.configureTableView()
                    self?.configureLoadingUI()
                    self?.fetchTextEntries()
                case .fetchedEntries:
                    self?.configureLoadedUI()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

extension EntriesView: UITableViewDelegate {

}
