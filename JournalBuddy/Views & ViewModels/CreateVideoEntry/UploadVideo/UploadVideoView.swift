//
//  UploadVideoView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import CoreMedia
import UIKit

class UploadVideoView: UIView, MainView {
    private lazy var videoPlayerView = VideoPlayerView(player: viewModel.videoPlayer)

    private lazy var videoPlayerCenterButton = SFSymbolButton(symbol: VideoPlayerMediaButtonType.play.image)
    private lazy var presentMediaControlsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentMediaControls))
    private lazy var dismissMediaControlsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMediaControls))

    var viewModel: UploadVideoViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: UploadVideoViewModel) {
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

        videoPlayerCenterButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        videoPlayerCenterButton.contentHorizontalAlignment = .fill
        videoPlayerCenterButton.contentVerticalAlignment = .fill
    }

    func constrain() {
        addConstrainedSubview(videoPlayerView)
        videoPlayerView.addConstrainedSubviews(videoPlayerCenterButton/*, restartVideoButton*/)

        NSLayoutConstraint.activate([
            videoPlayerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            videoPlayerView.heightAnchor.constraint(equalToConstant: 480),
            videoPlayerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoPlayerView.widthAnchor.constraint(equalToConstant: 270),

            videoPlayerCenterButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
            videoPlayerCenterButton.heightAnchor.constraint(equalToConstant: 80),
            videoPlayerCenterButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
            videoPlayerCenterButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func makeAccessible() {

    }
    
    func subscribeToPublishers() {
        viewModel.videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) { [weak self] time in
            if time.seconds == self?.viewModel.videoPlayerCurrentItemLengthInSeconds {
                self?.videoPlayerCurrentItemIsFinished()
            }
        }
    }
    
    /// Configures `videoPlayerCenterButton` every time the user interacts with it. For example, whent the user presses play, this method ensures that
    /// `videoPlayerCenterButton` changes to a pause button.
    /// - Parameters:
    ///   - selectorToRemove: The `Selector` to remove from `videoPlayerCenterButton` so that `selectorToAdd` gets triggered when the button is tapped.
    ///   - selectorToAdd: The `Selector` to add to `videoPlayerCenterButton`. Replaces `selectorToRemove`.
    ///   - newMediaButtonType: The type of button that `videoPlayerCenterButton` is to become.
    func configureMediaButton(remove selectorToRemove: Selector, add selectorToAdd: Selector, newMediaButtonType: VideoPlayerMediaButtonType) {
        videoPlayerCenterButton.setImage(newMediaButtonType.image, for: .normal)
        videoPlayerCenterButton.removeTarget(self, action: selectorToRemove, for: .touchUpInside)
        videoPlayerCenterButton.addTarget(self, action: selectorToAdd, for: .touchUpInside)
    }
    
    /// Configures the restart button when the video player's video reaches the end of its duration.
    func videoPlayerCurrentItemIsFinished() {
        configureMediaButton(remove: #selector(playButtonTapped), add: #selector(restartButtonTapped), newMediaButtonType: .restart)
        presentMediaControls()
    }

    @objc func playButtonTapped() {
        viewModel.videoPlayerPlayButtonTapped()
        configureMediaButton(remove: #selector(playButtonTapped), add: #selector(pauseButtonTapped), newMediaButtonType: .pause)
        dismissMediaControls()
    }

    @objc func pauseButtonTapped() {
        viewModel.videoPlayerPauseButtonTapped()
        configureMediaButton(remove: #selector(pauseButtonTapped), add: #selector(playButtonTapped), newMediaButtonType: .play)
        presentMediaControls()
    }

    @objc func restartButtonTapped() {
        viewModel.videoPlayerRestartButtonTapped()
        configureMediaButton(remove: #selector(restartButtonTapped), add: #selector(pauseButtonTapped), newMediaButtonType: .pause)
        dismissMediaControls()
    }

    @objc func presentMediaControls() {
        videoPlayerView.removeGestureRecognizer(presentMediaControlsTapGestureRecognizer)
        videoPlayerView.addGestureRecognizer(dismissMediaControlsTapGestureRecognizer)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.videoPlayerCenterButton.alpha = 1
        }
    }

    @objc func dismissMediaControls() {
        videoPlayerView.removeGestureRecognizer(dismissMediaControlsTapGestureRecognizer)
        videoPlayerView.addGestureRecognizer(presentMediaControlsTapGestureRecognizer)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.videoPlayerCenterButton.alpha = 0
        }
    }
}
