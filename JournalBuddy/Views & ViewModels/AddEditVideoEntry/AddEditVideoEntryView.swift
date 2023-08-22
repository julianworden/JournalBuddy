//
//  AddEditVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class AddEditVideoEntryView: UIView, MainView {
    var viewModel: AddEditVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: ViewModel) {
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
