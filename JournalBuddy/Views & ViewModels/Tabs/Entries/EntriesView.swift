//
//  EntriesView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class EntriesView: UIView, MainView {
    private lazy var entryTypeStack = UIStackView(
        arrangedSubviews: [
            textEntryButton,
            videoEntryButton,
            voiceEntryButton
        ]
    )
    private lazy var textEntryButton = PrimaryButton(title: "Text")
    private lazy var videoEntryButton = PrimaryButton(title: "Video")
    private lazy var voiceEntryButton = PrimaryButton(title: "Voice")
    private lazy var tableView = MainTableView()
    private lazy var tableViewDataSource = TextEntryTableViewDataSource(
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

        configure()
        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        entryTypeStack.spacing = 12
        if UIApplication.shared.preferredContentSizeCategory > .accessibilityLarge {
            entryTypeStack.axis = .horizontal
        }
        
        textEntryButton.titleLabel?.numberOfLines = 1
        textEntryButton.addTarget(self, action: #selector(textEntryButtonTapped), for: .touchUpInside)
        
        videoEntryButton.backgroundColor = .disabled
        videoEntryButton.titleLabel?.numberOfLines = 1
        videoEntryButton.addTarget(self, action: #selector(videoEntryButtonTapped), for: .touchUpInside)
        
        voiceEntryButton.backgroundColor = .disabled
        voiceEntryButton.titleLabel?.numberOfLines = 1
        voiceEntryButton.addTarget(self, action: #selector(voiceEntryButtonTapped), for: .touchUpInside)
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
            .sink { [weak self] notification in
                let newContentSizeCategory = notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as! UIContentSizeCategory
                if newContentSizeCategory > .accessibilityLarge {
                    self?.entryTypeStack.axis = .vertical
                } else {
                    self?.entryTypeStack.axis = .horizontal
                }
            }
            .store(in: &cancellables)
    }

    func makeAccessible() { }

    func constrain() {
        addConstrainedSubviews(fetchingEntriesActivityIndicator, entryTypeStack, tableView)

        NSLayoutConstraint.activate([
            entryTypeStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            entryTypeStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            entryTypeStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
            entryTypeStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            
            textEntryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            textEntryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),
            
            videoEntryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            videoEntryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),
            
            voiceEntryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            voiceEntryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),

            tableView.topAnchor.constraint(equalTo: entryTypeStack.bottomAnchor),
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

        entryTypeStack.isHidden = true

        fetchingEntriesActivityIndicator.color = .primaryElement
        fetchingEntriesActivityIndicator.hidesWhenStopped = true
        fetchingEntriesActivityIndicator.startAnimating()
    }

    func configureTableView() {
        tableView.register(
            TextEntryTableViewCell.self,
            forCellReuseIdentifier: TextEntryTableViewCell.reuseID
        )
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
    }

    func configureFetchedEntriesUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        entryTypeStack.isHidden = false
        tableView.isHidden = false
    }
    
    @objc func textEntryButtonTapped() {
        textEntryButton.backgroundColor = .primaryElement
        videoEntryButton.backgroundColor = .disabled
        voiceEntryButton.backgroundColor = .disabled
    }
    
    @objc func videoEntryButtonTapped() {
        textEntryButton.backgroundColor = .disabled
        videoEntryButton.backgroundColor = .primaryElement
        voiceEntryButton.backgroundColor = .disabled
    }
    
    @objc func voiceEntryButtonTapped() {
        textEntryButton.backgroundColor = .disabled
        videoEntryButton.backgroundColor = .disabled
        voiceEntryButton.backgroundColor = .primaryElement
    }
}

extension EntriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let tappedEntry = viewModel.textEntries[indexPath.row]
        delegate?.entriesViewDidSelectTextEntry(tappedEntry)
    }
}
