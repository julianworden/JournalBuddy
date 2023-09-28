//
//  ListenToVoiceEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/27/23.
//

import AVFoundation
import Combine
import UIKit

class ListenToVoiceEntryView: UIView, MainView {
    private lazy var playImage = UIImage(
        systemName: "play.circle.fill",
        withConfiguration: .createVideoViewButton
    )!
    
    private lazy var fetchingVoiceEntryActivityIndicator = UIActivityIndicatorView(style: .large)
    private lazy var contentStack = UIStackView(
        arrangedSubviews: [
            audioControlButton,
            audioPlayerTimelineSlider
        ]
    )
    private lazy var audioControlButton = SFSymbolButton(symbol: playImage)
    private lazy var audioPlayerTimelineSlider = TimelineSlider()
    
    let viewModel: ListenToVoiceEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ListenToVoiceEntryViewModel) {
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
        
        fetchingVoiceEntryActivityIndicator.color = .primaryElement
        
        contentStack.axis = .vertical
        
        fetchingVoiceEntryActivityIndicator.isHidden = true
        fetchingVoiceEntryActivityIndicator.hidesWhenStopped = true
        
        audioControlButton.contentHorizontalAlignment = .fill
        audioControlButton.contentVerticalAlignment = .fill
        audioControlButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        audioPlayerTimelineSlider.addTarget(self, action: #selector(userDidTouchDownTimelineSlider), for: .touchDown)
        audioPlayerTimelineSlider.addTarget(self, action: #selector(userDidMoveTimelineSlider), for: .valueChanged)
    }
    
    func constrain() {
        addConstrainedSubviews(fetchingVoiceEntryActivityIndicator, contentStack)
        
        NSLayoutConstraint.activate([
            fetchingVoiceEntryActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingVoiceEntryActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            audioControlButton.heightAnchor.constraint(equalToConstant: 180),
            audioControlButton.widthAnchor.constraint(equalToConstant: 180),
            
            audioPlayerTimelineSlider.widthAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingVoiceEntry:
                    self?.presentFetchingVoiceEntryUI()
                case .fetchedVoiceEntry:
                    self?.presentFetchedVoiceEntryUI()
                case .deletingVoiceEntry:
                    self?.disableControls()
                case .audioPlayingHasFinished:
                    self?.audioPlayingHasFinished()
                case .error(_):
                    self?.enableControls()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.audioPlayer
            .publisher(for: \.currentItem?.status)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.viewModel.viewState = .fetchedVoiceEntry
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func startUpdatingPlaybackTimelineSlider() {
        viewModel.audioPlayerPeriodicTimeObserver = viewModel.audioPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(
                value: 1,
                timescale: 1
            ),
            queue: .main,
            using: { [weak self] time in
                guard let self else { return }
                
                if time.seconds < viewModel.playerCurrentItemDuration {
                    self.audioPlayerTimelineSlider.setValue(Float(time.seconds), animated: true)
                } else if time.seconds == viewModel.playerCurrentItemDuration {
                    self.audioPlayingHasFinished()
                }
            }
        )
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
    
    func presentFetchingVoiceEntryUI() {
        fetchingVoiceEntryActivityIndicator.isHidden = false
        contentStack.isHidden = true
        fetchingVoiceEntryActivityIndicator.startAnimating()
    }
    
    func presentFetchedVoiceEntryUI() {
        fetchingVoiceEntryActivityIndicator.stopAnimating()
        contentStack.isHidden = false
        audioPlayerTimelineSlider.maximumValue = Float(viewModel.playerCurrentItemDuration)
    }
    
    func enableControls() {
        audioControlButton.isEnabled = true
        audioPlayerTimelineSlider.isEnabled = true
    }
    
    func disableControls() {
        audioControlButton.isEnabled = false
        audioPlayerTimelineSlider.isEnabled = false
    }
    
    @objc func playButtonTapped() {
        viewModel.startPlaying()
        
        configureAudioControlButton(
            remove: #selector(playButtonTapped),
            add: #selector(pauseButtonTapped),
            newControlButtonType: .pause
        )
        
        startUpdatingPlaybackTimelineSlider()
    }
    
    @objc func pauseButtonTapped() {
        viewModel.pausePlaying()
        
        configureAudioControlButton(
            remove: #selector(pauseButtonTapped),
            add: #selector(playButtonTapped),
            newControlButtonType: .play
        )
    }
    
    @objc func restartButtonTapped() {
        Task {
            await viewModel.seekAudioPlayer(to: CMTimeValue(0))
            audioPlayerTimelineSlider.setValue(0, animated: true)
            
            viewModel.startPlaying()
            
            configureAudioControlButton(
                remove: #selector(restartButtonTapped),
                add: #selector(pauseButtonTapped),
                newControlButtonType: .pause
            )
            
            startUpdatingPlaybackTimelineSlider()
        }
    }
    
    @objc func audioPlayingHasFinished() {
        configureAudioControlButton(
            remove: #selector(pauseButtonTapped),
            add: #selector(restartButtonTapped),
            newControlButtonType: .restart
        )

        audioPlayerTimelineSlider.setValue(Float(viewModel.playerCurrentItemDuration), animated: true)
    }
    
    @objc func userDidTouchDownTimelineSlider() {
        viewModel.pausePlaying()
    }
    
    @objc func userDidMoveTimelineSlider(_ sender: UISlider) {
        if sender.value == Float(viewModel.playerCurrentItemDuration) {
            audioPlayingHasFinished()
        } else {
            Task {
                await viewModel.seekAudioPlayer(to: CMTimeValue(sender.value))
                playButtonTapped()
            }
        }
    }
}
