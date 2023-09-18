//
//  EntriesView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class EntriesView: UIView, MainView {
    private lazy var entryTypeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: getEntryTypeSelectorFlowLayout())
    private lazy var entryTypeCollectionViewDataSourceAndDelegate = EntryTypeCollectionViewDataSourceAndDelegate(entryTypeSelector: entryTypeCollectionView)
    private lazy var tableView = MainTableView()
    private lazy var tableViewDataSource = EntriesViewTableViewDataSource(
        viewModel: viewModel,
        tableView: tableView
    )
    private lazy var fetchingEntriesActivityIndicator = UIActivityIndicatorView(style: .medium)

    let viewModel: EntriesViewModel
    weak var delegate: EntriesViewDelegate?
    var cancellables = Set<AnyCancellable>()
    var entryTypeCollectionViewHeightAnchor: NSLayoutConstraint!

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

        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] _ in
                guard let self else { return }

                let entryTypeCellTextHeight = EntryType.video.pluralRawValue.size(withAttributes: [.font: UIFontMetrics.avenirNextBoldBody])
                let entryTypeCellHeight = entryTypeCellTextHeight.height + 10
                self.entryTypeCollectionViewHeightAnchor.constant = entryTypeCellHeight
            }
            .store(in: &cancellables)
    }

    func makeAccessible() { }

    func constrain() {
        addConstrainedSubviews(entryTypeCollectionView, tableView, fetchingEntriesActivityIndicator)

        let entryTypeCellTextHeight = EntryType.video.pluralRawValue.size(withAttributes: [.font: UIFontMetrics.avenirNextBoldBody])
        entryTypeCollectionViewHeightAnchor = entryTypeCollectionView.heightAnchor.constraint(equalToConstant: entryTypeCellTextHeight.height + 10)

        NSLayoutConstraint.activate([
            entryTypeCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            entryTypeCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            entryTypeCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            entryTypeCollectionViewHeightAnchor,

            tableView.topAnchor.constraint(equalTo: entryTypeCollectionView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            fetchingEntriesActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingEntriesActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func configureFetchingEntriesUI() {
        backgroundColor = .background

        tableView.isHidden = true

        entryTypeCollectionView.backgroundColor = .background
        entryTypeCollectionView.showsHorizontalScrollIndicator = false
        entryTypeCollectionView.isHidden = true

        fetchingEntriesActivityIndicator.color = .primaryElement
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
        entryTypeCollectionView.dataSource = entryTypeCollectionViewDataSourceAndDelegate
        entryTypeCollectionView.delegate = entryTypeCollectionViewDataSourceAndDelegate

        fetchingEntriesActivityIndicator.stopAnimating()
        entryTypeCollectionView.isHidden = false
        tableView.isHidden = false
    }

    func getEntryTypeSelectorFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }
}

extension EntriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let tappedEntry = viewModel.textEntries[indexPath.row]
        delegate?.entriesViewDidSelectTextEntry(tappedEntry)
    }
}
