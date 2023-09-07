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
    private lazy var videoPlayerView = VideoPlayerView(player: viewModel.videoPlayer)
    private lazy var videoPlayerCenterMediaButton = SFSymbolButton(symbol: VideoPlayerMediaButtonType.play.image)
    private lazy var videoPlayerTimelineSlider = UISlider()
    private lazy var presentMediaControlsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentMediaControls))
    private lazy var dismissMediaControlsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMediaControls))
    private lazy var underVideoPlayerStack = UIStackView(
        arrangedSubviews: [
            saveToDeviceToggleStack,
            saveToDeviceExplanationLabel,
            uploadButton,
            savingToDeviceStack,
            uploadingStack
        ]
    )
    private lazy var saveToDeviceToggleStack = UIStackView(arrangedSubviews: [saveToDeviceLabel, saveToDeviceSwitch])
    private lazy var saveToDeviceLabel = UILabel()
    private lazy var saveToDeviceSwitch = UISwitch()
    private lazy var saveToDeviceExplanationLabel = UILabel()
    private lazy var uploadButton = PrimaryButton(title: "Upload")
    private lazy var savingToDeviceStack = UIStackView(arrangedSubviews: [savingToDeviceProgressView, savingToDeviceLabel])
    private lazy var savingToDeviceProgressView = UIProgressView(progressViewStyle: .bar)
    private lazy var savingToDeviceLabel = UILabel()
    private lazy var uploadingStack = UIStackView(arrangedSubviews: [uploadingProgressView, uploadingProgressViewLabelStack])
    private lazy var uploadingProgressView = UIProgressView(progressViewStyle: .bar)
    private lazy var uploadingProgressViewLabelStack = UIStackView(
        arrangedSubviews: [
            uploadingProgressViewLabel,
            uploadingProgressViewActivityIndicator
        ]
    )
    private lazy var uploadingProgressViewLabel = UILabel()
    private lazy var uploadingProgressViewActivityIndicator = UIActivityIndicatorView(style: .medium)
    
    /// The timer that controls when the media controls are automatically hidden after they're shown.
    var hideMediaControlsTimer: Timer?
    
    var viewModel: UploadVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UploadVideoEntryViewModel) {
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
        
        underVideoPlayerStack.axis = .vertical
        underVideoPlayerStack.spacing = 15
        
        if viewModel.videoWasSelectedFromLibrary {
            // No need to offer the user the option to save to device if they're uploading a video
            // that's already on their device
            saveToDeviceToggleStack.isHidden = true
        } else {
            configureSaveToDeviceToggleUI()
        }
        
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        
        savingToDeviceStack.isHidden = true
        uploadingStack.isHidden = true
    }
    
    func makeAccessible() {
        saveToDeviceLabel.adjustsFontForContentSizeCategory = true
        saveToDeviceExplanationLabel.adjustsFontForContentSizeCategory = true
        uploadingProgressViewLabel.adjustsFontForContentSizeCategory = true
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .videoEntryIsSavingToDevice:
                    self.configureSavingToDeviceProgressViewUI()
                    self.presentSavingToDeviceUI()
                    self.configureUploadingProgressViewUI()
                    self.presentUploadingUI()
                case .videoEntryWasSavedToDevice:
                    self.savingToDeviceProgressView.setProgress(1.0, animated: true)
                case .videoEntryIsUploading:
                    // If video was saved to device, uploading UI was already configured
                    if !self.viewModel.saveVideoToDevice {
                        self.configureUploadingProgressViewUI()
                        self.presentUploadingUI()
                    }
                case .videoEntryWasUploaded:
                    self.uploadingProgressViewLabel.text = "Uploaded."
                    self.uploadingProgressViewActivityIndicator.isHidden = true
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .videoIsUploading)
            .sink { [weak self] notification in
                guard let loadingProgress = notification.userInfo?[NotificationConstants.uploadingProgress] as? Double else {
                    return
                }
                
                self?.uploadingProgressView.setProgress(Float(loadingProgress), animated: true)
                
                if loadingProgress == 1.0 {
                    self?.uploadingProgressViewLabel.text = "Finalizing..."
                    self?.uploadingProgressViewActivityIndicator.startAnimating()
                    self?.uploadingProgressViewActivityIndicator.isHidden = false
                }
            }
            .store(in: &cancellables)
        
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
    
    func constrain() {
        addConstrainedSubviews(videoPlayerView, underVideoPlayerStack)
        videoPlayerView.addConstrainedSubviews(videoPlayerCenterMediaButton, videoPlayerTimelineSlider)
        
        NSLayoutConstraint.activate([
            videoPlayerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -3),
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
            
            underVideoPlayerStack.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: 15),
            underVideoPlayerStack.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            underVideoPlayerStack.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            
            uploadButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 49),
            
            savingToDeviceProgressView.heightAnchor.constraint(equalToConstant: 12),
            savingToDeviceProgressView.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            savingToDeviceProgressView.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            
            uploadingProgressView.heightAnchor.constraint(equalToConstant: 12),
            uploadingProgressView.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            uploadingProgressView.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor)
        ])
    }
    
    func configureSaveToDeviceToggleUI() {
        saveToDeviceToggleStack.distribution = .equalCentering
        
        saveToDeviceLabel.text = "Save to Device"
        saveToDeviceLabel.font = UIFontMetrics.avenirNextRegularBody
        saveToDeviceLabel.textAlignment = .left
        saveToDeviceLabel.textColor = .primaryElement
        saveToDeviceLabel.numberOfLines = 0
        
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
        savingToDeviceStack.axis = .vertical
        savingToDeviceStack.spacing = 7
        savingToDeviceStack.alignment = .leading
        
        savingToDeviceProgressView.layer.cornerRadius = 6
        savingToDeviceProgressView.clipsToBounds = true
        savingToDeviceProgressView.progressTintColor = .primaryElement
        savingToDeviceProgressView.trackTintColor = .disabled
        
        savingToDeviceLabel.font = UIFontMetrics.avenirNextBoldFootnote
        savingToDeviceLabel.textColor = .primaryElement
    }
    
    func configureUploadingProgressViewUI() {
        uploadingStack.axis = .vertical
        uploadingStack.spacing = 7
        uploadingStack.alignment = .leading
        
        uploadingProgressView.layer.cornerRadius = 6
        uploadingProgressView.clipsToBounds = true
        uploadingProgressView.progressTintColor = .primaryElement
        uploadingProgressView.trackTintColor = .disabled
        
        uploadingProgressViewLabelStack.spacing = 5
        
        uploadingProgressViewLabel.font = UIFontMetrics.avenirNextBoldFootnote
        uploadingProgressViewLabel.textColor = .primaryElement
        
        uploadingProgressViewActivityIndicator.hidesWhenStopped = true
        uploadingProgressViewActivityIndicator.isHidden = true
        uploadingProgressViewActivityIndicator.color = .primaryElement
    }
    
    func presentUploadingUI() {
        uploadingProgressViewLabel.text = "Uploading..."
        savingToDeviceLabel.text = "Saved."
        uploadingStack.isHidden = false
        saveToDeviceToggleStack.isHidden = true
        saveToDeviceExplanationLabel.isHidden = true
        uploadButton.isHidden = true
    }
    
    func presentSavingToDeviceUI() {
        savingToDeviceLabel.text = "Saving..."
        uploadingProgressViewLabel.text = "Waiting..."
        savingToDeviceStack.isHidden = false
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
#warning("Don't show timeline when video needs to be restarted, only show restart button.")
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
    
    @objc func saveToDeviceSwitchTapped(_ sender: UISwitch) {
        viewModel.saveVideoToDevice = sender.isOn
    }
    
    @objc func uploadButtonTapped() {
        Task {
            await viewModel.uploadButtonTapped()
        }
    }
}