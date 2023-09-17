//
//  UploadVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import CoreMedia
import UIKit

class UploadVideoEntryView: UIView, MainView {
    private lazy var mainScrollView = UIScrollView()
    private lazy var mainScrollViewContentStack = UIStackView(
        arrangedSubviews: [
            videoPlayerView,
            underVideoPlayerStack
        ]
    )
    private lazy var videoPlayerView = VideoPlayerView(player: viewModel.videoPlayer)
    /// The button in the middle of the video player. This button's appearance and target depends on what the video player is currently doing. It
    /// alternates between a play button, pause button, and restart button.
    private lazy var videoPlayerCenterMediaButton = SFSymbolButton(symbol: VideoPlayerMediaButtonType.play.image)
    private lazy var videoPlayerTimelineSlider = TimelineSlider()
    private lazy var underVideoPlayerStack = UIStackView(
        arrangedSubviews: [
            saveToDeviceToggleStack,
            saveToDeviceExplanationLabel,
            uploadButton,
            savingStack,
            uploadingStack
        ]
    )
    private lazy var saveToDeviceToggleStack = UIStackView(
        arrangedSubviews: [
            saveToDeviceLabel,
            saveToDeviceSwitch
        ]
    )
    private lazy var saveToDeviceLabel = UILabel()
    private lazy var saveToDeviceSwitch = UISwitch()
    private lazy var saveToDeviceExplanationLabel = UILabel()
    private lazy var uploadButton = PrimaryButton(title: "Upload")
    private lazy var savingStack = ProgressViewStack()
    private lazy var uploadingStack = ProgressViewStack()
    
    private lazy var presentMediaControlsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(presentMediaControls)
    )
    private lazy var dismissMediaControlsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(dismissMediaControls)
    )
    /// The timer that controls when the media controls are automatically hidden after they're shown.
    var hideMediaControlsTimer: Timer?
    
    var viewModel: UploadVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UploadVideoEntryViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        configure()
        makeAccessible()
        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .background
        
        mainScrollView.showsVerticalScrollIndicator = false
        
        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.spacing = UIConstants.mainStackViewSpacing
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true
        mainScrollViewContentStack.alignment = .center
        
        videoPlayerTimelineSlider.addTarget(self, action: #selector(userDidTouchDownTimelineSlider), for: .touchDown)
        videoPlayerTimelineSlider.addTarget(self, action: #selector(userDidMoveTimelineSlider), for: .valueChanged)
        
        videoPlayerCenterMediaButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        videoPlayerCenterMediaButton.contentHorizontalAlignment = .fill
        videoPlayerCenterMediaButton.contentVerticalAlignment = .fill
        
        underVideoPlayerStack.axis = .vertical
        underVideoPlayerStack.spacing = 15
        
        if viewModel.videoWasSelectedFromLibrary {
            // Necessary because saveToDevice switch has an intrinsic content size, so just
            // not configuring it isn't enough to hide it
            saveToDeviceToggleStack.isHidden = true
        } else {
            configureSaveToDeviceToggleUI()
        }
        
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        
        savingStack.isHidden = true
        uploadingStack.isHidden = true
    }
    
    func makeAccessible() {
        saveToDeviceLabel.adjustsFontForContentSizeCategory = true
        saveToDeviceExplanationLabel.adjustsFontForContentSizeCategory = true
    }
    
    func subscribeToPublishers() {
        subscribeToViewStateUpdates()
        subscribeToVideoUploadingProgress()
        subscribeToVideoTimelineUpdates()
        subscribeToVideoPlayerStatusUpdates()
    }
    
    func constrain() {
        addConstrainedSubviews(mainScrollView)
        mainScrollView.addConstrainedSubviews(mainScrollViewContentStack)
        videoPlayerView.addConstrainedSubviews(videoPlayerCenterMediaButton, videoPlayerTimelineSlider)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            mainScrollViewContentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainScrollViewContentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainScrollViewContentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainScrollViewContentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),

            videoPlayerView.heightAnchor.constraint(equalToConstant: 480),
            videoPlayerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoPlayerView.widthAnchor.constraint(equalToConstant: 270),
            
            videoPlayerCenterMediaButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
            videoPlayerCenterMediaButton.heightAnchor.constraint(equalToConstant: 80),
            videoPlayerCenterMediaButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
            videoPlayerCenterMediaButton.widthAnchor.constraint(equalToConstant: 80),
            
            videoPlayerTimelineSlider.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor, constant: 10),
            videoPlayerTimelineSlider.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor, constant: -10),
            videoPlayerTimelineSlider.bottomAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: -10),
            
            underVideoPlayerStack.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            underVideoPlayerStack.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            
            uploadButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 49),
        ])
    }
    
    func subscribeToViewStateUpdates() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .videoEntryIsSavingToDevice:
                    self.configureSavingToDeviceProgressViewUI()
                    self.configureUploadingProgressViewUI()
                    self.presentSavingToDeviceUI()
                    self.presentUploadingUI()
                case .videoEntryWasSavedToDevice:
                    self.savingStack.updateProgress(to: 1.0)
                    self.savingStack.updateLabelText(to: "Saved.")
                    self.uploadingStack.updateLabelText(to: "Uploading...")
                case .videoEntryIsUploading:
                    // If video was saved to device, uploading UI was already configured
                    if !self.viewModel.saveVideoToDevice {
                        self.uploadingStack.updateLabelText(to: "Uploading...")
                        self.configureUploadingProgressViewUI()
                        self.presentUploadingUI()
                    }
                case .videoEntryWasUploaded:
                    self.uploadingStack.updateLabelText(to: "Uploaded.")
                    self.uploadingStack.hideActivityIndicator()
                case .error(_):
                    configureErrorUI()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVideoUploadingProgress() {
        NotificationCenter.default.publisher(for: .videoIsUploading)
            .sink { [weak self] notification in
                guard let loadingProgress = notification.userInfo?[NotificationConstants.uploadingProgress] as? Double else {
                    return
                }
                
                self?.uploadingStack.updateProgress(to: Float(loadingProgress))

                
                if loadingProgress == 1.0 {
                    self?.uploadingStack.updateLabelText(to: "Finalizing...")
                    self?.uploadingStack.presentActivityIndicator()
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVideoTimelineUpdates() {
        viewModel.videoPlayerPeriodicTimeObserver = viewModel.videoPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 1),
            queue: .main
        ) { [weak self] time in
            self?.videoPlayerTimelineSlider.setValue(Float(time.seconds), animated: true)
            
            if time.seconds == self?.viewModel.videoPlayerCurrentItemLengthInSeconds {
                self?.videoPlayerCurrentItemIsFinished()
            }
        }
    }
    
    /// Creates a subscriber that sets the video player's timeline's maximum value once the video player's `AVPlayerItem.Status`  is `.readyToPlay`.
    /// This is necessary because the video player will not return the correct length of its `currentItem` unless it's ready to play.
    func subscribeToVideoPlayerStatusUpdates() {
        viewModel.videoPlayer.publisher(for: \.currentItem?.status)
            .sink { [weak self] status in
                guard status == .readyToPlay,
                      let self else { return }
                
                self.videoPlayerTimelineSlider.maximumValue = Float(self.viewModel.videoPlayerCurrentItemLengthInSeconds)
            }
            .store(in: &cancellables)
    }
    
    func configureSaveToDeviceToggleUI() {
        saveToDeviceToggleStack.distribution = .equalCentering
        saveToDeviceToggleStack.alignment = .center
        
        saveToDeviceLabel.text = "Save to Device"
        saveToDeviceLabel.font = UIFontMetrics.avenirNextRegularBody
        saveToDeviceLabel.textAlignment = .left
        saveToDeviceLabel.textColor = .primaryElement
        saveToDeviceLabel.numberOfLines = 2
        saveToDeviceLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        saveToDeviceSwitch.onTintColor = .primaryElement
        saveToDeviceSwitch.backgroundColor = .disabled
        saveToDeviceSwitch.layer.cornerRadius = 16
        saveToDeviceSwitch.thumbTintColor = .background
        saveToDeviceSwitch.clipsToBounds = true
        saveToDeviceSwitch.addTarget(self, action: #selector(saveToDeviceSwitchTapped), for: .valueChanged)
        
        let saveToDeviceExplanationLabelParagraphStyle = NSMutableParagraphStyle()
        saveToDeviceExplanationLabelParagraphStyle.lineSpacing = 5
        let saveToDeviceExplanationLabelText = NSMutableAttributedString(
            string: "We recommend saving your entry to your device in case something goes wrong during uploading."
        )
        saveToDeviceExplanationLabelText.addAttribute(
            .paragraphStyle,
            value: saveToDeviceExplanationLabelParagraphStyle,
            range: NSRange(location: 0, length: saveToDeviceExplanationLabelText.length)
        )
        saveToDeviceExplanationLabel.attributedText = saveToDeviceExplanationLabelText
        saveToDeviceExplanationLabel.font = UIFontMetrics.avenirNextRegularFootnote
        saveToDeviceExplanationLabel.textAlignment = .left
        saveToDeviceExplanationLabel.textColor = .primaryElement
        saveToDeviceExplanationLabel.numberOfLines = 0
    }
    
    func configureSavingToDeviceProgressViewUI() {
        videoPlayerTimelineSlider.isEnabled = false
        videoPlayerCenterMediaButton.isEnabled = false
        videoPlayerView.isUserInteractionEnabled = false
        savingStack.updateLabelText(to: "Saving...")
        uploadingStack.updateLabelText(to: "Waiting...")
    }
    
    func configureUploadingProgressViewUI() {
        videoPlayerTimelineSlider.isEnabled = false
        videoPlayerCenterMediaButton.isEnabled = false
        videoPlayerView.isUserInteractionEnabled = false
    }
    
    func configureErrorUI() {
        videoPlayerCenterMediaButton.isEnabled = true
        videoPlayerTimelineSlider.isEnabled = true
        saveToDeviceToggleStack.isHidden = false
        savingStack.isHidden = true
        uploadingStack.isHidden = true
        uploadButton.isHidden = false
        videoPlayerView.isUserInteractionEnabled = true
        
        if !viewModel.videoWasSelectedFromLibrary {
            saveToDeviceToggleStack.isHidden = false
            saveToDeviceExplanationLabel.isHidden = false
        }
    }
    
    func presentUploadingUI() {
        uploadingStack.isHidden = false
        saveToDeviceToggleStack.isHidden = true
        saveToDeviceExplanationLabel.isHidden = true
        uploadButton.isHidden = true
    }
    
    func presentSavingToDeviceUI() {
        savingStack.isHidden = false
        saveToDeviceToggleStack.isHidden = true
        saveToDeviceExplanationLabel.isHidden = true
        uploadButton.isHidden = true
    }
    
    /// Configures `videoPlayerCenterMediaButton` every time the user interacts with it. For example, whent the user presses play, this method ensures that
    /// `videoPlayerCenterMediaButton` changes to a pause button.
    /// - Parameters:
    ///   - selectorToRemove: The `Selector` to remove from `videoPlayerCenterMediaButton` so that `selectorToAdd` gets triggered when the button is tapped.
    ///   - selectorToAdd: The `Selector` to add to `videoPlayerCenterMediaButton`. Replaces `selectorToRemove`.
    ///   - newMediaButtonType: The type of button that `videoPlayerCenterMediaButton` is to become.
    func configureMediaButton(
        remove selectorToRemove: Selector,
        add selectorToAdd: Selector,
        newMediaButtonType: VideoPlayerMediaButtonType
    ) {
        videoPlayerCenterMediaButton.setImage(newMediaButtonType.image, for: .normal)
        videoPlayerCenterMediaButton.removeTarget(self, action: selectorToRemove, for: .touchUpInside)
        videoPlayerCenterMediaButton.addTarget(self, action: selectorToAdd, for: .touchUpInside)
    }
    
    /// Configures the restart button when the video player's video reaches the end of its duration.
    func videoPlayerCurrentItemIsFinished() {
        hideMediaControlsTimer?.invalidate()
        hideMediaControlsTimer = nil
        configureMediaButton(remove: #selector(playButtonTapped), add: #selector(restartButtonTapped), newMediaButtonType: .restart)
        videoPlayerView.addGestureRecognizer(dismissMediaControlsTapGestureRecognizer)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.videoPlayerCenterMediaButton.alpha = 1
            self?.videoPlayerTimelineSlider.alpha = 1
        }
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
        hideMediaControlsTimer?.invalidate()
        hideMediaControlsTimer = nil
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.videoPlayerCenterMediaButton.alpha = 0
            self?.videoPlayerTimelineSlider.alpha = 0
        }
    }
    
    @objc func userDidTouchDownTimelineSlider() {
        hideMediaControlsTimer?.invalidate()
        hideMediaControlsTimer = nil
        viewModel.videoPlayer.pause()
    }
    
    @objc func userDidMoveTimelineSlider(_ sender: UISlider) {
        Task {
            await viewModel.seekVideoPlayer(to: Double(sender.value))
            playButtonTapped()
        }
    }
    
    @objc func saveToDeviceSwitchTapped(_ sender: UISwitch) {
        viewModel.saveVideoToDevice = sender.isOn
    }
    
    @objc func uploadButtonTapped() {
        Task {
            pauseButtonTapped()
            await viewModel.uploadButtonTapped()
        }
    }
}
