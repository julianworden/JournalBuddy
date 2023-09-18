//
//  AddEditGoalView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Combine
import UIKit

final class AddEditGoalView: UIView, MainView {
    let viewModel: AddEditGoalViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AddEditGoalViewModel) {
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
