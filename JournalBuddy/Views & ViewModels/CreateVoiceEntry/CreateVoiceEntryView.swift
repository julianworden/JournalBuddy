//
//  CreateVoiceEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Combine
import UIKit

class CreateVoiceEntryView: UIView, MainView {
    let viewModel: CreateVoiceEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CreateVoiceEntryViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .background
    }
    
    func constrain() {
        
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        
    }
}
