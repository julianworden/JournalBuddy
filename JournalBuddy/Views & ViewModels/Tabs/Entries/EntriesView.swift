//
//  EntriesView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

#warning("Make no content found view scrollable for dynamic type sizes.")
#warning("Make entry type selector disabled when custom menu is visible")

class EntriesView: UIView, MainView {
    enum CollectionViewType: Int {
        case video = 0
        case voice
    }
    
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
    private lazy var textEntryTableView = MainTableView()
    private lazy var textEntryTableViewDataSource = TextEntryTableViewDataSource(
        delegate: self,
        viewModel: viewModel,
        tableView: textEntryTableView
    )
    private lazy var fetchingNextTextEntryBatchActivityIndicator = UIActivityIndicatorView(
        style: .medium
    )
    private lazy var fetchingNextVoiceEntryBatchActivityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var videoEntryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private lazy var videoEntryCollectionViewDataSource = VideoEntryCollectionViewDataSource(
        viewModel: viewModel,
        collectionView: videoEntryCollectionView
    )
    private lazy var voiceEntryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private lazy var voiceEntryCollectionViewDataSource = VoiceEntryCollectionViewDataSource(
        collectionView: voiceEntryCollectionView,
        viewModel: viewModel
    )
    private lazy var noEntriesFoundView = NoContentFoundView(
        title: "No Text Entries Found",
        message: "You can use the plus button to create a text entry."
    )
    private lazy var fetchingEntriesActivityIndicator = UIActivityIndicatorView(style: .medium)
    
    var voiceEntryCollectionViewBottomConstraint: NSLayoutConstraint!

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
        backgroundColor = .background
        entryTypeStack.spacing = 12
        if UIApplication.shared.preferredContentSizeCategory > .accessibilityLarge {
            entryTypeStack.axis = .vertical
        }
        entryTypeStack.isHidden = true

        fetchingEntriesActivityIndicator.color = .primaryElement
        fetchingEntriesActivityIndicator.hidesWhenStopped = true
        fetchingEntriesActivityIndicator.startAnimating()
        
        fetchingNextVoiceEntryBatchActivityIndicator.color = .primaryElement
        fetchingNextVoiceEntryBatchActivityIndicator.hidesWhenStopped = true
        fetchingNextVoiceEntryBatchActivityIndicator.isHidden = true
                
        textEntryButton.titleLabel?.numberOfLines = 1
        textEntryButton.addTarget(self, action: #selector(textEntryButtonTapped), for: .touchUpInside)
        
        videoEntryButton.backgroundColor = .disabled
        videoEntryButton.titleLabel?.numberOfLines = 1
        videoEntryButton.addTarget(self, action: #selector(videoEntryButtonTapped), for: .touchUpInside)
        
        voiceEntryButton.backgroundColor = .disabled
        voiceEntryButton.titleLabel?.numberOfLines = 1
        voiceEntryButton.addTarget(self, action: #selector(voiceEntryButtonTapped), for: .touchUpInside)
        
        fetchingNextTextEntryBatchActivityIndicator.color = .primaryElement
        fetchingNextTextEntryBatchActivityIndicator.hidesWhenStopped = true
        
        textEntryTableView.isHidden = true
        textEntryTableView.register(
            TextEntryTableViewCell.self,
            forCellReuseIdentifier: TextEntryTableViewCell.reuseID
        )
        textEntryTableView.delegate = self
        textEntryTableView.dataSource = textEntryTableViewDataSource
        textEntryTableView.showsVerticalScrollIndicator = false
        
        videoEntryCollectionView.isHidden = true
        videoEntryCollectionView.backgroundColor = .background
        videoEntryCollectionView.showsVerticalScrollIndicator = false
        videoEntryCollectionView.dataSource = videoEntryCollectionViewDataSource
        videoEntryCollectionView.delegate = self
        videoEntryCollectionView.tag = CollectionViewType.video.rawValue
        
        voiceEntryCollectionView.isHidden = true
        voiceEntryCollectionView.backgroundColor = .background
        voiceEntryCollectionView.showsVerticalScrollIndicator = false
        voiceEntryCollectionView.dataSource = voiceEntryCollectionViewDataSource
        voiceEntryCollectionView.delegate = self
        voiceEntryCollectionView.tag = CollectionViewType.voice.rawValue
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingTextEntries, .fetchingVideoEntries, .fetchingVoiceEntries:
                    self?.presentLoadingUI()
                case .fetchedTextEntries:
                    self?.presentFetchedTextEntriesUI()
                case .noTextEntriesFound:
                    self?.presentNoTextEntriesFoundUI()
                case .fetchedVideoEntries:
                    self?.presentFetchedVideoEntriesUI()
                case .noVideoEntriesFound:
                    self?.presentNoVideoEntriesFoundUI()
                case .fetchedVoiceEntries:
                    self?.presentFetchedVoiceEntriesUI()
                case .noVoiceEntriesFound:
                    self?.presentNoVoiceEntriesFoundUI()
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
        addConstrainedSubviews(
            fetchingEntriesActivityIndicator,
            fetchingNextVoiceEntryBatchActivityIndicator,
            entryTypeStack,
            noEntriesFoundView,
            textEntryTableView,
            videoEntryCollectionView,
            voiceEntryCollectionView
        )
        
        voiceEntryCollectionViewBottomConstraint = voiceEntryCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            entryTypeStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            entryTypeStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            entryTypeStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
            entryTypeStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            
            fetchingEntriesActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingEntriesActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            fetchingNextVoiceEntryBatchActivityIndicator.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            fetchingNextVoiceEntryBatchActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                
            noEntriesFoundView.topAnchor.constraint(greaterThanOrEqualTo: entryTypeStack.bottomAnchor, constant: 12),
            noEntriesFoundView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            noEntriesFoundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            noEntriesFoundView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
            noEntriesFoundView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            noEntriesFoundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            textEntryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            textEntryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),
            
            videoEntryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            videoEntryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),
            
            voiceEntryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            voiceEntryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),

            textEntryTableView.topAnchor.constraint(equalTo: entryTypeStack.bottomAnchor),
            textEntryTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            textEntryTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textEntryTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            videoEntryCollectionView.topAnchor.constraint(equalTo: entryTypeStack.bottomAnchor, constant: 15),
            videoEntryCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            videoEntryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            videoEntryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            voiceEntryCollectionView.topAnchor.constraint(equalTo: entryTypeStack.bottomAnchor, constant: 15),
            voiceEntryCollectionViewBottomConstraint,
            voiceEntryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            voiceEntryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }
    
    func presentLoadingUI() {
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        voiceEntryCollectionView.isHidden = true
        noEntriesFoundView.isHidden = true
        fetchingEntriesActivityIndicator.isHidden = false
        fetchingEntriesActivityIndicator.startAnimating()
    }
    
    func presentFetchedTextEntriesUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        entryTypeStack.isHidden = false
        textEntryTableView.isHidden = false
        videoEntryCollectionView.isHidden = true
        voiceEntryCollectionView.isHidden = true
    }
    
    func presentNoTextEntriesFoundUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        entryTypeStack.isHidden = false
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        voiceEntryCollectionView.isHidden = true
        noEntriesFoundView.updateTitle(to: "No Text Entries Found")
        noEntriesFoundView.updateSubtitle(to: "You can use the plus button to create a new text entry.")
        noEntriesFoundView.isHidden = false
    }
    
    func presentFetchedVideoEntriesUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = false
        voiceEntryCollectionView.isHidden = true
    }
    
    func presentNoVideoEntriesFoundUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        voiceEntryCollectionView.isHidden = true
        noEntriesFoundView.updateTitle(to: "No Video Entries Found")
        noEntriesFoundView.updateSubtitle(to: "You can use the plus button to create a video entry.")
        noEntriesFoundView.isHidden = false
    }
    
    func presentFetchedVoiceEntriesUI () {
        fetchingEntriesActivityIndicator.stopAnimating()
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        voiceEntryCollectionView.isHidden = false
        noEntriesFoundView.isHidden = true
    }
    
    func presentNoVoiceEntriesFoundUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        voiceEntryCollectionView.isHidden = true
        noEntriesFoundView.updateTitle(to: "No Voice Entries Found")
        noEntriesFoundView.updateSubtitle(to: "You can use the plus button to create a voice entry.")
        noEntriesFoundView.isHidden = false
    }
    
    func updateTextEntryTableViewIfNeeded() {
        textEntryTableViewDataSource.updateDataSourceIfNeeded()
    }
    
    @objc func textEntryButtonTapped() {
        if viewModel.selectedEntryType != EntriesViewModel.SelectedEntryType.text {
            Task {
                textEntryButton.backgroundColor = .primaryElement
                videoEntryButton.backgroundColor = .disabled
                voiceEntryButton.backgroundColor = .disabled
                viewModel.selectedEntryType = .text
                
                if !viewModel.textEntriesQueryPerformed {
                    await viewModel.fetchFirstTextEntryBatch()
                } else if viewModel.textEntries.isEmpty {
                    presentNoTextEntriesFoundUI()
                } else if !viewModel.textEntries.isEmpty {
                    presentFetchedTextEntriesUI()
                }
            }
        }
    }
    
    @objc func videoEntryButtonTapped() {
        if viewModel.selectedEntryType != EntriesViewModel.SelectedEntryType.video {
            Task {
                textEntryButton.backgroundColor = .disabled
                videoEntryButton.backgroundColor = .primaryElement
                voiceEntryButton.backgroundColor = .disabled
                viewModel.selectedEntryType = .video
                
                if !viewModel.videoEntriesQueryPerformed {
                    await viewModel.fetchFirstVideoEntryBatch()
                } else if viewModel.videoEntries.isEmpty {
                    presentNoVideoEntriesFoundUI()
                } else if !viewModel.videoEntries.isEmpty {
                    presentFetchedVideoEntriesUI()
                }
            }
        }
    }
    
    @objc func voiceEntryButtonTapped() {
        if viewModel.selectedEntryType != EntriesViewModel.SelectedEntryType.voice {
            Task {
                textEntryButton.backgroundColor = .disabled
                videoEntryButton.backgroundColor = .disabled
                voiceEntryButton.backgroundColor = .primaryElement
                viewModel.selectedEntryType = .voice
                
                if !viewModel.voiceEntriesQueryPerformed {
                    await viewModel.fetchFirstVoiceEntryBatch()
                } else if viewModel.voiceEntries.isEmpty {
                    presentNoVoiceEntriesFoundUI()
                } else if !viewModel.voiceEntries.isEmpty {
                    presentFetchedVoiceEntriesUI()
                }
            }
        }
    }
}

extension EntriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let tappedEntry = viewModel.textEntries[indexPath.row]
        delegate?.entriesViewDidSelectTextEntry(tappedEntry)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.textEntries.count - 1 &&
            viewModel.textEntries.count % FBConstants.textEntryBatchSize == 0 {
            Task {
                let textEntriesCountBeforeUpdate = viewModel.textEntries.count
                
                presentLoadingNextTextEntryBatchUI()
                await viewModel.fetchNextTextEntryBatch()
                
                let textEntriesCountAfterUpdate = viewModel.textEntries.count
                // Get the index to which the table view should scroll after fetching new entries
                let amountOfNewTextEntries = textEntriesCountAfterUpdate - textEntriesCountBeforeUpdate
                
                presentLoadedNextTextEntryBatchUI(for: tableView, amountOfNewTextEntries: amountOfNewTextEntries)
            }
        }
    }
    
    func presentLoadingNextTextEntryBatchUI() {
        fetchingNextTextEntryBatchActivityIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        fetchingNextTextEntryBatchActivityIndicator.startAnimating()
        textEntryTableView.tableFooterView = fetchingNextTextEntryBatchActivityIndicator
        textEntryTableView.tableFooterView?.isHidden = false
    }
    
    /// Presents the user with a given table view after its been updated with new text entries by scrolling to the
    /// most recent of the newly fetched data.
    /// - Parameters:
    ///   - tableView: The table view receiving the update.
    ///   - amountOfNewTextEntries: The amount of new text entries that are being added to the table view's data source.
    ///   This property is used to determine where the scroll view should scroll.
    func presentLoadedNextTextEntryBatchUI(for tableView: UITableView, amountOfNewTextEntries: Int) {
        fetchingNextTextEntryBatchActivityIndicator.stopAnimating()
        textEntryTableView.tableFooterView = nil
        tableView.scrollToRow(
            at: IndexPath(row: viewModel.textEntries.count - amountOfNewTextEntries, section: 0),
            at: .bottom,
            animated: true
        )
    }
}

extension EntriesView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case CollectionViewType.video.rawValue:
            return CGSize(width: (collectionView.bounds.width / 3) - 10, height: 192)
        case CollectionViewType.voice.rawValue:
            return CGSize(width: (collectionView.bounds.width / 3) - 10, height: 100)
        default:
            print("❌ Unknown collection view tag sent to delegate method.")
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case CollectionViewType.video.rawValue:
            let selectedVideoEntry = viewModel.videoEntries[indexPath.item]
            delegate?.entriesViewDidSelectVideoEntry(selectedVideoEntry)
        case CollectionViewType.voice.rawValue:
            let selectedVoiceEntry = viewModel.voiceEntries[indexPath.item]
            delegate?.entriesViewDidSelectVoiceEntry(selectedVoiceEntry)
        default:
            print("❌ Unknown collection view tag sent to delegate method.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case CollectionViewType.video.rawValue:
            if indexPath.item == viewModel.videoEntries.count - 1 &&
                viewModel.videoEntries.count % FBConstants.videoEntryBatchSize == 0 {
                fetchNewVideoEntryBatch(for: collectionView)
            }
        case CollectionViewType.voice.rawValue:
            if indexPath.item == viewModel.voiceEntries.count - 1 &&
                viewModel.voiceEntries.count % FBConstants.voiceEntryBatchSize == 0 {
                fetchNewVoiceEntryBatch(for: collectionView)
            }
        default:
            print("❌ Unknown collection view tag sent to delegate method.")
        }
    }
    
    func fetchNewVideoEntryBatch(for collectionView: UICollectionView) {
        Task {
            let videoEntriesCountBeforeUpdate = viewModel.videoEntries.count
            await viewModel.fetchNextVideoEntryBatch()
            let videoEntriesCountAfterUpdate = viewModel.videoEntries.count
            let totalNewVideoEntries = videoEntriesCountAfterUpdate - videoEntriesCountBeforeUpdate
            collectionView.scrollToItem(
                at: IndexPath(row: viewModel.videoEntries.count - totalNewVideoEntries, section: 0),
                at: .bottom,
                animated: true
            )
        }
    }
    
    func fetchNewVoiceEntryBatch(for collectionView: UICollectionView) {
        Task {
            let voiceEntriesCountBeforeUpdate = viewModel.voiceEntries.count
            await viewModel.fetchNextVoiceEntryBatch()
            let voiceEntriesCountAfterUpdate = viewModel.voiceEntries.count
            let totalNewVoiceEntries = voiceEntriesCountAfterUpdate - voiceEntriesCountBeforeUpdate
            collectionView.scrollToItem(
                at: IndexPath(row: viewModel.voiceEntries.count - totalNewVoiceEntries, section: 0),
                at: .bottom,
                animated: true
            )
        }
    }
}

extension EntriesView: TextEntryTableViewDataSourceDelegate {
    func scrollTableViewToTop() {
        guard !viewModel.textEntries.isEmpty else { return }
        
        textEntryTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
}
