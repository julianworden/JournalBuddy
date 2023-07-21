//
//  NewTextEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class NewTextEntryView: UIView, MainView {
    let viewModel: NewTextEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: NewTextEntryViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configureDefaultUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDefaultUI() {
        backgroundColor = .systemBackground
    }

    func constrain() {

    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {

    }
}
