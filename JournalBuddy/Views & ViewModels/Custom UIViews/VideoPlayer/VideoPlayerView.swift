//
//  VideoPlayerView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/24/23.
//

import AVFoundation
import Combine
import UIKit

class VideoPlayerView: UIView {
    /// The button in the middle of the video player. This button's appearance and target depends on what the video player is currently doing. It
    /// alternates between a play button, pause button, and restart button.
    private lazy var centerMediaButton = SFSymbolButton(symbol: VideoPlayerMediaButtonType.play.image)
    private lazy var timelineSlider = TimelineSlider()
    
    private lazy var presentControlsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(presentMediaControls)
    )
    private lazy var dismissControlsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(dismissMediaControls)
    )
    
    @Published var playerIsReadyToPlay = false
    var cancellables = Set<AnyCancellable>()
    /// The periodic time observer for the video player. This is created in in `UploadVideoView` and then removed
    /// after `UploadVideoViewController` disappears.
    var playerPeriodicTimeObserver: Any?
    /// The timer that controls when the media controls are automatically hidden after they're shown.
    var hideControlsTimer: Timer?
    
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var playerCurrentItemLengthInSeconds: Double {
        guard let currentItem = player?.currentItem else {
            return 0
        }

        return currentItem.duration.seconds
    }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    init(videoPlayerURL: URL) {
        super.init(frame: .zero)

        self.player = AVPlayer(url: videoPlayerURL)
        
        configure()
        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        timelineSlider.addTarget(self, action: #selector(userDidTouchDownTimelineSlider), for: .touchDown)
        timelineSlider.addTarget(self, action: #selector(userDidMoveTimelineSlider), for: .valueChanged)
        
        centerMediaButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        centerMediaButton.contentHorizontalAlignment = .fill
        centerMediaButton.contentVerticalAlignment = .fill
    }
    
    func subscribeToPublishers() {
        subscribeToVideoProgressUpdates()
        subscribeToVideoPlayerStatusUpdates()
    }
    
    func constrain() {
        addConstrainedSubviews(centerMediaButton, timelineSlider)
        
        NSLayoutConstraint.activate([
            centerMediaButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerMediaButton.heightAnchor.constraint(equalToConstant: 80),
            centerMediaButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerMediaButton.widthAnchor.constraint(equalToConstant: 80),
            
            timelineSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            timelineSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            timelineSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    private func subscribeToVideoProgressUpdates() {
        guard let player else {
            print("❌ Attempted to subscribe to timeline updates before player's initialization.")
            return
        }
        
        playerPeriodicTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 1),
            queue: .main
        ) { [weak self] time in
            self?.timelineSlider.setValue(Float(time.seconds), animated: true)
            
            if time.seconds == self?.playerCurrentItemLengthInSeconds {
                self?.playerCurrentItemIsFinished()
            }
        }
    }
    
    /// Creates a subscriber that sets the video player's timeline's maximum value once the video player's `AVPlayerItem.Status`  is `.readyToPlay`.
    /// This is necessary because the video player will not return the correct length of its `currentItem` unless it's ready to play.
    private func subscribeToVideoPlayerStatusUpdates() {
        player?.publisher(for: \.currentItem?.status)
            .sink { [weak self] status in
                guard status == .readyToPlay,
                      let self else { return }
                
                self.timelineSlider.maximumValue = Float(self.playerCurrentItemLengthInSeconds)
                self.playerIsReadyToPlay = true
            }
            .store(in: &cancellables)
    }
    
    /// Configures the restart button when the video player's video reaches the end of its duration.
    func playerCurrentItemIsFinished() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = nil
        configureMediaButton(remove: #selector(playButtonTapped), add: #selector(restartButtonTapped), newMediaButtonType: .restart)
        addGestureRecognizer(dismissControlsTapGestureRecognizer)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.centerMediaButton.alpha = 1
            self?.timelineSlider.alpha = 1
        }
    }
    
    /// Configures `centerMediaButton` every time the user interacts with it. For example, whent the user presses play, this method ensures that
    /// `playerCenterMediaButton` changes to a pause button.
    /// - Parameters:
    ///   - selectorToRemove: The `Selector` to remove from `playerCenterMediaButton` so that `selectorToAdd` gets triggered when the button is tapped.
    ///   - selectorToAdd: The `Selector` to add to `playerCenterMediaButton`. Replaces `selectorToRemove`.
    ///   - newMediaButtonType: The type of button that `playerCenterMediaButton` is to become.
    func configureMediaButton(
        remove selectorToRemove: Selector,
        add selectorToAdd: Selector,
        newMediaButtonType: VideoPlayerMediaButtonType
    ) {
        centerMediaButton.setImage(newMediaButtonType.image, for: .normal)
        centerMediaButton.removeTarget(self, action: selectorToRemove, for: .touchUpInside)
        centerMediaButton.addTarget(self, action: selectorToAdd, for: .touchUpInside)
    }
    
    /// Starts a timer that fires every 1 second to determine when the media controls should automatically be hidden after the user has shown them. Hides media controls
    /// after 2 seconds.
    func startHideMediaControlsTimer() {
        var timerDuration = 0
        
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            timerDuration += 1
            
            if timerDuration == 2 {
                self?.dismissMediaControls()
                self?.hideControlsTimer?.invalidate()
                self?.hideControlsTimer = nil
            }
        })
    }
    
    func disable() {
        timelineSlider.isEnabled = false
        centerMediaButton.isEnabled = false
        isUserInteractionEnabled = false
    }
    
    func enable() {
        centerMediaButton.isEnabled = true
        timelineSlider.isEnabled = true
        isUserInteractionEnabled = true
    }
    
    @objc func playButtonTapped() {
        player?.play()
        configureMediaButton(remove: #selector(playButtonTapped), add: #selector(pauseButtonTapped), newMediaButtonType: .pause)
        dismissMediaControls()
    }
    
    @objc func pauseButtonTapped() {
        player?.pause()
        configureMediaButton(remove: #selector(pauseButtonTapped), add: #selector(playButtonTapped), newMediaButtonType: .play)
        presentMediaControls()
    }
    
    @objc func restartButtonTapped() {
        player?.seek(
            to: CMTime(value: 0, timescale: 1),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
        player?.play()
        configureMediaButton(remove: #selector(restartButtonTapped), add: #selector(pauseButtonTapped), newMediaButtonType: .pause)
        dismissMediaControls()
    }
    
    @objc func presentMediaControls() {
        removeGestureRecognizer(presentControlsTapGestureRecognizer)
        addGestureRecognizer(dismissControlsTapGestureRecognizer)
        startHideMediaControlsTimer()
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.centerMediaButton.alpha = 1
            self?.timelineSlider.alpha = 1
        }
    }
    
    @objc func dismissMediaControls() {
        removeGestureRecognizer(dismissControlsTapGestureRecognizer)
        addGestureRecognizer(presentControlsTapGestureRecognizer)
        hideControlsTimer?.invalidate()
        hideControlsTimer = nil
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.centerMediaButton.alpha = 0
            self?.timelineSlider.alpha = 0
        }
    }
    
    @objc func userDidTouchDownTimelineSlider() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = nil
        player?.pause()
    }
    
    @objc func userDidMoveTimelineSlider(_ sender: UISlider) {
        Task {
            await player?.seek(
                to: CMTime(value: CMTimeValue(sender.value), timescale: 1),
                toleranceBefore: CMTime(value: 1, timescale: 2),
                toleranceAfter: CMTime(value: 1, timescale: 2)
            )
            playButtonTapped()
        }
    }
}
