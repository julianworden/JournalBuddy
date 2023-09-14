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
    private lazy var audioControlButton = SFSymbolButton(symbol: micImage)
    
    let viewModel: CreateVoiceEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CreateVoiceEntryViewModel) {
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
        
    }
    
    @objc func recordButtonTapped() {
        viewModel.startRecording()
    }
}
