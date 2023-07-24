//
//  SignUpView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import Combine
import UIKit

class SignUpView: UIView, MainView {
    let viewModel: SignUpViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDefaultViewState() {
        backgroundColor = .systemBackground
    }

    func constrain() {

    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {

    }
}
