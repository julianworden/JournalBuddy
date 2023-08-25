//
//  UploadVideoView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import UIKit

class UploadVideoView: UIView, MainView {
    private lazy var videoPlayerView = VideoPlayerView(player: viewModel.videoPlayer)

    var viewModel: UploadVideoViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: UploadVideoViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configure()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .background
    }

    func constrain() {
        addConstrainedSubview(videoPlayerView)

        NSLayoutConstraint.activate([
            videoPlayerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            videoPlayerView.heightAnchor.constraint(equalToConstant: 480),
            videoPlayerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoPlayerView.widthAnchor.constraint(equalToConstant: 270),
        ])
    }
    
    func makeAccessible() {

    }
    
    func subscribeToPublishers() {

    }
}
