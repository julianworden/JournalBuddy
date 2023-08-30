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
    private lazy var videoPlayerCenterMediaButton = SFSymbolButton(symbol: VideoPlayerMediaButtonType.play.image)
    private lazy var videoPlayerTimelineSlider = UISlider()
    private lazy var presentMediaControlsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentMediaControls))
    private lazy var dismissMediaControlsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMediaControls))
    
    /// The timer that controls when the media controls are automatically hidden after they're shown.
    var hideMediaControlsTimer: Timer?

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

        videoPlayerTimelineSlider.tintColor = .primaryElement
        videoPlayerTimelineSlider.minimumValue = 0
        videoPlayerTimelineSlider.maximumValue = 1
        videoPlayerTimelineSlider.thumbTintColor = .background
        videoPlayerTimelineSlider.maximumTrackTintColor = .disabled
        videoPlayerTimelineSlider.isContinuous = false

        videoPlayerTimelineSlider.addTarget(self, action: #selector(userDidMoveTimelineSlider), for: .valueChanged)

        videoPlayerCenterMediaButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        videoPlayerCenterMediaButton.contentHorizontalAlignment = .fill
        videoPlayerCenterMediaButton.contentVerticalAlignment = .fill
    }

    func constrain() {
        addConstrainedSubview(videoPlayerView)
        videoPlayerView.addConstrainedSubviews(videoPlayerCenterMediaButton, videoPlayerTimelineSlider)

        NSLayoutConstraint.activate([
            videoPlayerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            videoPlayerView.heightAnchor.constraint(equalToConstant: 480),
            videoPlayerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoPlayerView.widthAnchor.constraint(equalToConstant: 270),

            videoPlayerCenterMediaButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
            videoPlayerCenterMediaButton.heightAnchor.constraint(equalToConstant: 80),
            videoPlayerCenterMediaButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
            videoPlayerCenterMediaButton.widthAnchor.constraint(equalToConstant: 80),

            videoPlayerTimelineSlider.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor, constant: 10),
            videoPlayerTimelineSlider.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor, constant: -10),
            videoPlayerTimelineSlider.bottomAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: -10)
        ])
    }
    
    func makeAccessible() {

    }
    
    func subscribeToPublishers() {
        viewModel.videoPlayerPeriodicTimeObserver = viewModel.videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) { [weak self] time in
            self?.videoPlayerTimelineSlider.setValue(Float(time.seconds), animated: true)

            if time.seconds == self?.viewModel.videoPlayerCurrentItemLengthInSeconds {
                self?.videoPlayerCurrentItemIsFinished()
            }
        }

        // Necessary because AVPlayer's currentItem duration is not accessible until its status is .readyToPlay
        viewModel.videoPlayer.publisher(for: \.currentItem?.status)
            .sink { [weak self] status in
                guard status == .readyToPlay,
                      let self else { return }

                self.videoPlayerTimelineSlider.maximumValue = Float(self.viewModel.videoPlayerCurrentItemLengthInSeconds)
            }
            .store(in: &cancellables)
    }
    
    /// Configures `videoPlayerCenterMediaButton` every time the user interacts with it. For example, whent the user presses play, this method ensures that
    /// `videoPlayerCenterMediaButton` changes to a pause button.
    /// - Parameters:
    ///   - selectorToRemove: The `Selector` to remove from `videoPlayerCenterMediaButton` so that `selectorToAdd` gets triggered when the button is tapped.
    ///   - selectorToAdd: The `Selector` to add to `videoPlayerCenterMediaButton`. Replaces `selectorToRemove`.
    ///   - newMediaButtonType: The type of button that `videoPlayerCenterMediaButton` is to become.
    func configureMediaButton(remove selectorToRemove: Selector, add selectorToAdd: Selector, newMediaButtonType: VideoPlayerMediaButtonType) {
        videoPlayerCenterMediaButton.setImage(newMediaButtonType.image, for: .normal)
        videoPlayerCenterMediaButton.removeTarget(self, action: selectorToRemove, for: .touchUpInside)
        videoPlayerCenterMediaButton.addTarget(self, action: selectorToAdd, for: .touchUpInside)
    }
    
    /// Configures the restart button when the video player's video reaches the end of its duration.
    func videoPlayerCurrentItemIsFinished() {
        hideMediaControlsTimer?.invalidate()
        hideMediaControlsTimer = nil
        configureMediaButton(remove: #selector(playButtonTapped), add: #selector(restartButtonTapped), newMediaButtonType: .restart)
        presentMediaControls()
    }
    
    /// Starts a timer that fires every 1 second to determine when the media controls should automatically be hidden after the user has shown them. Hides media controls
    /// after 2 seconds.
    func startHideMediaControlsTimer() {
        var timerDuration = 0
        
        hideMediaControlsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            timerDuration += 1
            
            if timerDuration == 2 {
                self?.dismissMediaControls()
                self?.hideMediaControlsTimer?.invalidate()
                self?.hideMediaControlsTimer = nil
            }
        })
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
        startHideMediaControlsTimer()

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.videoPlayerCenterMediaButton.alpha = 1
            self?.videoPlayerTimelineSlider.alpha = 1
        }
    }

    @objc func dismissMediaControls() {
        videoPlayerView.removeGestureRecognizer(dismissMediaControlsTapGestureRecognizer)
        videoPlayerView.addGestureRecognizer(presentMediaControlsTapGestureRecognizer)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.videoPlayerCenterMediaButton.alpha = 0
            self?.videoPlayerTimelineSlider.alpha = 0
        }
    }

    @objc func userDidMoveTimelineSlider(_ sender: UISlider) {
        viewModel.seekVideoPlayer(to: Double(sender.value))
    }
}
