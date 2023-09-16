//
//  CreateVoiceEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Combine
import UIKit

class CreateVoiceEntryView: UIView, MainView {
    private lazy var micImage = UIImage(
        systemName: "mic.circle.fill",
        withConfiguration: .createVideoViewButton
    )!
    private lazy var stopImage = UIImage(
        systemName: "stop.circle.fill",
        withConfiguration: .createVideoViewButton
    )!
    
    private lazy var contentStack = UIStackView(
        arrangedSubviews: [
            recordingTimerView,
            audioControlButton,
            audioPlayerTimelineSlider,
            newRecordingButton,
            uploadButton,
            uploadingStack
        ]
    )
    private lazy var recordingTimerView = TimerView()
    private lazy var audioControlButton = SFSymbolButton(symbol: micImage)
    private lazy var audioPlayerTimelineSlider = TimelineSlider()
    private lazy var newRecordingButton = PrimaryButton(title: "New Recording")
    private lazy var uploadButton = PrimaryButton(title: "Upload")
    private lazy var uploadingStack = UIStackView(
        arrangedSubviews: [
            uploadingProgressView,
            uploadingProgressViewLabelStack
        ]
    )
    private lazy var uploadingProgressView = UIProgressView(progressViewStyle: .bar)
    private lazy var uploadingProgressViewLabelStack = UIStackView(
        arrangedSubviews: [
            uploadingProgressViewLabel,
            uploadingProgressViewActivityIndicator
        ]
    )
    private lazy var uploadingProgressViewLabel = UILabel()
    private lazy var uploadingProgressViewActivityIndicator = UIActivityIndicatorView(style: .medium)
    
    let viewModel: CreateVoiceEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CreateVoiceEntryViewModel) {
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
        
        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.alignment = .center
        
        recordingTimerView.setTimerLabelFont(UIFontMetrics.avenirNextRegularTitle2)
        
        audioControlButton.contentHorizontalAlignment = .fill
        audioControlButton.contentVerticalAlignment = .fill
        audioControlButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        
        audioPlayerTimelineSlider.isHidden = true
        audioPlayerTimelineSlider.addTarget(self, action: #selector(userDidTouchDownTimelineSlider), for: .touchDown)
        audioPlayerTimelineSlider.addTarget(self, action: #selector(userDidMoveTimelineSlider), for: .valueChanged)
        
        newRecordingButton.isHidden = true
        newRecordingButton.addTarget(self, action: #selector(newRecordingButtonTapped), for: .touchUpInside)
        
        uploadButton.isHidden = true
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        
        uploadingStack.isHidden = true
    }
    
    func constrain() {
        addConstrainedSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            audioControlButton.heightAnchor.constraint(equalToConstant: 180),
            audioControlButton.widthAnchor.constraint(equalToConstant: 180),
            
            audioPlayerTimelineSlider.widthAnchor.constraint(equalToConstant: 180),
            
            newRecordingButton.widthAnchor.constraint(equalToConstant: 270),
            newRecordingButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            uploadButton.widthAnchor.constraint(equalToConstant: 270),
            uploadButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            uploadingProgressView.heightAnchor.constraint(equalToConstant: 12),
            uploadingProgressView.widthAnchor.constraint(equalToConstant: 270)
        ])
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .audioPlayingHasFinished:
                    self?.audioPlayingHasFinished()
                case .uploadingVoiceEntry:
                    self?.configureUploadingUI()
                    self?.presentUploadingUI()
                case .uploadedVoiceEntry:
                    self?.uploadingProgressViewLabel.text = "Uploaded."
                    self?.uploadingProgressViewActivityIndicator.isHidden = true
                case .error(_):
                    self?.configureErrorUI()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .voiceEntryIsUploading)
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
    }
    
    func configureUploadingUI() {
        audioPlayerTimelineSlider.isEnabled = false
        audioControlButton.isEnabled = false
        
        uploadingStack.axis = .vertical
        uploadingStack.spacing = 7
        uploadingStack.alignment = .leading
        
        uploadingProgressView.layer.cornerRadius = 6
        uploadingProgressView.clipsToBounds = true
        uploadingProgressView.progressTintColor = .primaryElement
        uploadingProgressView.trackTintColor = .disabled
        
        uploadingProgressViewLabelStack.spacing = 5
        
        uploadingProgressViewLabel.text = "Uploading..."
        uploadingProgressViewLabel.font = UIFontMetrics.avenirNextBoldFootnote
        uploadingProgressViewLabel.textColor = .primaryElement
        uploadingProgressViewLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        uploadingProgressViewActivityIndicator.hidesWhenStopped = true
        uploadingProgressViewActivityIndicator.isHidden = true
        uploadingProgressViewActivityIndicator.color = .primaryElement
    }
    
    func configureErrorUI() {
        audioControlButton.isEnabled = true
        audioPlayerTimelineSlider.isEnabled = true
        newRecordingButton.isHidden = false
        uploadButton.isHidden = false
        uploadingStack.isHidden = true
    }
    
    func presentUploadingUI() {
        newRecordingButton.isHidden = true
        uploadButton.isHidden = true
        uploadingStack.isHidden = false
    }
    
    func configureAudioControlButton(
        remove selectorToRemove: Selector,
        add selectorToAdd: Selector,
        newControlButtonType: VoiceEntryControlButtonType
    ) {
        audioControlButton.setImage(
            newControlButtonType.image,
            for: .normal
        )
        audioControlButton.removeTarget(
            self,
            action: selectorToRemove,
            for: .touchUpInside
        )
        audioControlButton.addTarget(
            self,
            action: selectorToAdd,
            for: .touchUpInside
        )
    }
    
    /// Resets `recordingTimerView`'s text when the view appears.
    func setNewRecordingTimerLabelText() {
        recordingTimerView.updateTimerLabelText(with: "00:00 / 05:00")
    }
    
    func startUpdatingRecordingTimerLabel() {
        viewModel.recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            // Make sure the label isn't updated if the user tries to record for over 5 minutes
            if viewModel.recordingTimerDurationAsInt > 300 {
                stopButtonTapped()
            } else {
                self.recordingTimerView.updateTimerLabelText(
                    with: "\(self.viewModel.recordingTimerDurationAsInt.secondsAsTimerDurationString) / 05:00"
                )
            }
        }
    }
    
    func startUpdatingPlaybackTimelineSlider() {
        var playbackDuration = viewModel.audioPlayer.currentTime
        
        viewModel.playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            playbackDuration += 0.5
            
            if playbackDuration < self.viewModel.audioPlayer.duration {
                self.audioPlayerTimelineSlider.setValue(Float(playbackDuration), animated: true)
            }
        }
    }

    @objc func recordButtonTapped() {
        viewModel.startRecording()
        
        configureAudioControlButton(
            remove: #selector(recordButtonTapped),
            add: #selector(stopButtonTapped),
            newControlButtonType: .stop
        )
        
        newRecordingButton.isHidden = true
        uploadButton.isHidden = true
        audioPlayerTimelineSlider.isHidden = true
        recordingTimerView.isHidden = false
        
        startUpdatingRecordingTimerLabel()
  
        #warning("Try something like this later")
//        viewModel.recordButtonAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
//            guard let recordingVolume = self?.viewModel.getRecordingVolume() else { return }
//            
//            if recordingVolume < -100 {
//                UIView.animate(withDuration: 0.5) {
//                    self?.audioControlButton.transform = CGAffineTransform(scaleX: 1, y: 1)
//                }
//            } else {
//                UIView.animate(withDuration: 0.5) {
//                    self?.audioControlButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//                }
//            }
//        }
    }
    
    @objc func playButtonTapped() {
        viewModel.startPlaying()
        
        configureAudioControlButton(
            remove: #selector(playButtonTapped),
            add: #selector(pauseButtonTapped),
            newControlButtonType: .pause
        )
        
        startUpdatingPlaybackTimelineSlider()
        newRecordingButton.isHidden = true
        uploadButton.isHidden = true
    }
    
    @objc func pauseButtonTapped() {
        viewModel.pausePlaying()
        
        configureAudioControlButton(
            remove: #selector(pauseButtonTapped),
            add: #selector(playButtonTapped),
            newControlButtonType: .play
        )
        
        viewModel.playbackTimer?.invalidate()
        viewModel.playbackTimer = nil
        newRecordingButton.isHidden = false
        uploadButton.isHidden = false
    }
    
    @objc func stopButtonTapped() {
        viewModel.stopRecording()
        
        configureAudioControlButton(
            remove: #selector(stopButtonTapped),
            add: #selector(playButtonTapped),
            newControlButtonType: .play
        )
        
        audioPlayerTimelineSlider.maximumValue = Float(viewModel.audioPlayer.duration)
        audioPlayerTimelineSlider.setValue(0, animated: false)
        recordingTimerView.isHidden = true
        newRecordingButton.isHidden = false
        uploadButton.isHidden = false
        audioPlayerTimelineSlider.isHidden = false
    }
    
    @objc func restartButtonTapped() {
        viewModel.audioPlayer.currentTime = 0
        audioPlayerTimelineSlider.setValue(0, animated: true)
        
        viewModel.startPlaying()
        
        configureAudioControlButton(
            remove: #selector(restartButtonTapped),
            add: #selector(pauseButtonTapped),
            newControlButtonType: .pause
        )

        startUpdatingPlaybackTimelineSlider()
        newRecordingButton.isHidden = true
        uploadButton.isHidden = true
    }
    
    @objc func audioPlayingHasFinished() {
        configureAudioControlButton(
            remove: #selector(pauseButtonTapped),
            add: #selector(restartButtonTapped),
            newControlButtonType: .restart
        )
        
        viewModel.playbackTimer?.invalidate()
        viewModel.playbackTimer = nil
        audioPlayerTimelineSlider.setValue(Float(viewModel.audioPlayer.duration), animated: true)
        newRecordingButton.isHidden = false
        uploadButton.isHidden = false
    }
    
    @objc func userDidTouchDownTimelineSlider() {
        viewModel.pausePlaying()
        viewModel.playbackTimer?.invalidate()
        viewModel.playbackTimer = nil
    }
    
    @objc func userDidMoveTimelineSlider(_ sender: UISlider) {
        if sender.value == Float(viewModel.audioPlayer.duration) {
            audioPlayingHasFinished()
        } else {
            viewModel.audioPlayer.currentTime = TimeInterval(sender.value)
            playButtonTapped()
        }
    }
    
    @objc func newRecordingButtonTapped() {
        let audioRecorderDidDeleteRecording = viewModel.audioRecorder.deleteRecording()
        
        guard audioRecorderDidDeleteRecording else {
            viewModel.viewState = .error(
                message: VoiceEntryError.failedToStartNewRecording.localizedDescription
            )
            print("❌ Failed to delete audio recorder recording.")
            return
        }
        
        viewModel.audioPlayer = nil
        recordingTimerView.updateTimerLabelText(with: "00:00 / 05:00")
        recordButtonTapped()
    }
    
    @objc func uploadButtonTapped() {
        Task {
            await viewModel.uploadVoiceEntry()
        }
    }
}
