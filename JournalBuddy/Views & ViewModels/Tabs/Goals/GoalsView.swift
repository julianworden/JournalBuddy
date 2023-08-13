//
//  GoalsView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Combine
import UIKit

class GoalsView: UIView, MainView {
    private lazy var fetchingGoalsActivityIndicator = UIActivityIndicatorView(style: .large)

    let viewModel: GoalsViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: GoalsViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureFetchingGoalsUI() {
        backgroundColor = .background

        fetchingGoalsActivityIndicator.hidesWhenStopped = true
        fetchingGoalsActivityIndicator.startAnimating()
    }

    func constrain() {
        addConstrainedSubview(fetchingGoalsActivityIndicator)

        NSLayoutConstraint.activate([
            fetchingGoalsActivityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            fetchingGoalsActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func makeAccessible() {

    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchingGoals:
                    self?.configureFetchingGoalsUI()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
