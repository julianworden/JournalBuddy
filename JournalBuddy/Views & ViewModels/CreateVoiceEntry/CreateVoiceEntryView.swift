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
    private lazy var audioControlButton = SFSymbolButton(symbol: micImage)
    
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
        
        audioControlButton.contentHorizontalAlignment = .fill
        audioControlButton.contentVerticalAlignment = .fill
        audioControlButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    func constrain() {
        addConstrainedSubview(audioControlButton)
        
        NSLayoutConstraint.activate([
            audioControlButton.heightAnchor.constraint(equalToConstant: 180),
            audioControlButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            audioControlButton.widthAnchor.constraint(equalToConstant: 180),
            audioControlButton.centerXAnchor.constraint(equalTo: centerXAnchor)
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
                default:
                    break
                }
            }
            .store(in: &cancellables)
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
    
    @objc func recordButtonTapped() {
        viewModel.startRecording()
        
        configureAudioControlButton(
            remove: #selector(recordButtonTapped),
            add: #selector(stopButtonTapped),
            newControlButtonType: .stop
        )
  
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
    }
    
    @objc func pauseButtonTapped() {
        viewModel.pausePlaying()
        
        configureAudioControlButton(
            remove: #selector(pauseButtonTapped),
            add: #selector(playButtonTapped),
            newControlButtonType: .play
        )
    }
    
    @objc func stopButtonTapped() {
        viewModel.stopRecording()
        
        configureAudioControlButton(
            remove: #selector(stopButtonTapped),
            add: #selector(playButtonTapped),
            newControlButtonType: .play
        )
    }
    
    @objc func restartButtonTapped() {
        viewModel.startPlaying()
        
        configureAudioControlButton(
            remove: #selector(restartButtonTapped),
            add: #selector(pauseButtonTapped),
            newControlButtonType: .pause
        )
    }
    
    @objc func audioPlayingHasFinished() {
        configureAudioControlButton(
            remove: #selector(pauseButtonTapped),
            add: #selector(restartButtonTapped),
            newControlButtonType: .restart
        )
    }
}
