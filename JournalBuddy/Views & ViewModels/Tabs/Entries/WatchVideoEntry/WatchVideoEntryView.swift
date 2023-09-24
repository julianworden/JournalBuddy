//
//  WatchVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/24/23.
//

import Combine
import UIKit

final class WatchVideoEntryView: UIView, MainView {
    private lazy var fetchingVideoActivityIndicator = UIActivityIndicatorView(style: .large)
    private lazy var videoPlayer = VideoPlayerView(
        videoPlayerURL: URL(
            string: viewModel.videoEntry.downloadURL
        )!
    )
    
    let viewModel: WatchVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: WatchVideoEntryViewModel) {
        self.viewModel = viewModel
        
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
        
        fetchingVideoActivityIndicator.color = .primaryElement
        fetchingVideoActivityIndicator.hidesWhenStopped = true
        
        configureFetchingVideoEntryUI()
    }
    
    func configureFetchingVideoEntryUI() {
        videoPlayer.isHidden = true
        fetchingVideoActivityIndicator.startAnimating()
    }
    
    func configureFetchedVideoEntryUI() {
        fetchingVideoActivityIndicator.stopAnimating()
        videoPlayer.isHidden = false
    }
    
    func constrain() {
        addConstrainedSubviews(fetchingVideoActivityIndicator, videoPlayer)
        
        NSLayoutConstraint.activate([
            fetchingVideoActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingVideoActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            videoPlayer.heightAnchor.constraint(equalToConstant: 480),
            videoPlayer.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoPlayer.centerYAnchor.constraint(equalTo: centerYAnchor),
            videoPlayer.widthAnchor.constraint(equalToConstant: 270)
        ])
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        videoPlayer.$playerIsReadyToPlay
            .sink { [weak self] playerIsReadyToPlay in
                if playerIsReadyToPlay {
                    self?.configureFetchedVideoEntryUI()
                    self?.viewModel.viewState = .fetchedVideoEntry
                }
            }
            .store(in: &cancellables)
    }
}
