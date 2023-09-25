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
    private lazy var textEntryTableView = MainTableView()
    private lazy var textEntryTableViewDataSource = TextEntryTableViewDataSource(
        viewModel: viewModel,
        tableView: textEntryTableView
    )
    private lazy var videoEntryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var videoEntryCollectionViewDataSource = VideoEntryCollectionViewDataSource(
        viewModel: viewModel,
        collectionView: videoEntryCollectionView
    )
    private lazy var noEntriesFoundView = NoContentFoundView(
        title: "No Text Entries Found",
        message: "You can use the plus button to create a text entry."
    )
    private lazy var fetchingEntriesActivityIndicator = UIActivityIndicatorView(style: .large)

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
            entryTypeStack.axis = .horizontal
        }
        entryTypeStack.isHidden = true

        fetchingEntriesActivityIndicator.color = .primaryElement
        fetchingEntriesActivityIndicator.hidesWhenStopped = true
        fetchingEntriesActivityIndicator.startAnimating()
                
        textEntryButton.titleLabel?.numberOfLines = 1
        textEntryButton.addTarget(self, action: #selector(textEntryButtonTapped), for: .touchUpInside)
        
        videoEntryButton.backgroundColor = .disabled
        videoEntryButton.titleLabel?.numberOfLines = 1
        videoEntryButton.addTarget(self, action: #selector(videoEntryButtonTapped), for: .touchUpInside)
        
        voiceEntryButton.backgroundColor = .disabled
        voiceEntryButton.titleLabel?.numberOfLines = 1
        voiceEntryButton.addTarget(self, action: #selector(voiceEntryButtonTapped), for: .touchUpInside)
        
        textEntryTableView.isHidden = true
        textEntryTableView.register(
            TextEntryTableViewCell.self,
            forCellReuseIdentifier: TextEntryTableViewCell.reuseID
        )
        textEntryTableView.delegate = self
        textEntryTableView.dataSource = textEntryTableViewDataSource
        
        videoEntryCollectionView.isHidden = true
        videoEntryCollectionView.backgroundColor = .background
        videoEntryCollectionView.showsVerticalScrollIndicator = false
        videoEntryCollectionView.dataSource = videoEntryCollectionViewDataSource
        videoEntryCollectionView.delegate = self
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingTextEntries, .fetchingVideoEntries:
                    self?.presentLoadingUI()
                case .fetchedTextEntries:
                    self?.presentFetchedTextEntriesUI()
                case .noTextEntriesFound:
                    self?.presentNoTextEntriesFoundUI()
                case .fetchedVideoEntries:
                    self?.presentFetchedVideoEntriesUI()
                case .noVideoEntriesFound:
                    self?.presentNoVideoEntriesFoundUI()
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
            entryTypeStack,
            noEntriesFoundView,
            textEntryTableView,
            videoEntryCollectionView
        )

        NSLayoutConstraint.activate([
            entryTypeStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            entryTypeStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            entryTypeStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
            entryTypeStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            
            noEntriesFoundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noEntriesFoundView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
            noEntriesFoundView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            noEntriesFoundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
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

            fetchingEntriesActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingEntriesActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func presentLoadingUI() {
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        noEntriesFoundView.isHidden = true
        fetchingEntriesActivityIndicator.isHidden = false
        fetchingEntriesActivityIndicator.startAnimating()
    }
    
    func presentFetchedTextEntriesUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        entryTypeStack.isHidden = false
        textEntryTableView.isHidden = false
        videoEntryCollectionView.isHidden = true
    }
    
    func presentNoTextEntriesFoundUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        entryTypeStack.isHidden = false
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        noEntriesFoundView.updateTitle(to: "No Text Entries Found")
        noEntriesFoundView.updateSubtitle(to: "You can use the plus button to create a new text entry.")
        noEntriesFoundView.isHidden = false
    }
    
    func presentFetchedVideoEntriesUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = false
    }
    
    func presentNoVideoEntriesFoundUI() {
        fetchingEntriesActivityIndicator.stopAnimating()
        textEntryTableView.isHidden = true
        videoEntryCollectionView.isHidden = true
        noEntriesFoundView.updateTitle(to: "No Video Entries Found")
        noEntriesFoundView.updateSubtitle(to: "You can use the plus button to create a video entry.")
        noEntriesFoundView.isHidden = false
    }
    
    @objc func textEntryButtonTapped() {
        if viewModel.selectedEntryType != EntriesViewModel.SelectedEntryType.text {
            Task {
                textEntryButton.backgroundColor = .primaryElement
                videoEntryButton.backgroundColor = .disabled
                voiceEntryButton.backgroundColor = .disabled
                viewModel.selectedEntryType = .text
                
                if !viewModel.textEntriesQueryPerformed {
                    await viewModel.fetchTextEntries()
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
                    await viewModel.fetchVideoEntries()
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
            textEntryButton.backgroundColor = .disabled
            videoEntryButton.backgroundColor = .disabled
            voiceEntryButton.backgroundColor = .primaryElement
            viewModel.selectedEntryType = .voice
        }
    }
}

extension EntriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let tappedEntry = viewModel.textEntries[indexPath.row]
        delegate?.entriesViewDidSelectTextEntry(tappedEntry)
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
        return CGSize(width: (collectionView.bounds.width / 3) - 10, height: 192)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedVideoEntry = viewModel.videoEntries[indexPath.item]
        delegate?.entriesViewDidSelectVideoEntry(selectedVideoEntry)
    }
}
