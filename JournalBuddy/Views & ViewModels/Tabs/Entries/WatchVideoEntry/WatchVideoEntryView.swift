//
//  WatchVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/24/23.
//

import Combine
import UIKit

final class WatchVideoEntryView: UIView, MainView {
    let viewModel: WatchVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: WatchVideoEntryViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constrain() {
        
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        
    }
}
