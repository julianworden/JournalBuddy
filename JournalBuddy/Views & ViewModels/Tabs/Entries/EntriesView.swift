//
//  EntriesView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class EntriesView: UIView, MainView {
    var viewModel: EntriesViewModel

    var cancellables = Set<AnyCancellable>()

    init(viewModel: EntriesViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configureLoadedView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureLoadedView() {
        backgroundColor = .white
    }

    func constrain() {

    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {

    }
}
