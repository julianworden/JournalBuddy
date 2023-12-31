//
//  HomeViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import Combine
import SwiftPlus
import UIKit

class HomeViewController: UIViewController, MainViewController {
    // Temporary button for development
    private lazy var logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonTapped))

    weak var coordinator: HomeCoordinator?
    let viewModel: HomeViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: HomeCoordinator, viewModel: HomeViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = HomeView(viewModel: viewModel, delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            configure()
            subscribeToPublishers()
            await viewModel.fetchThreeMostRecentlyCompletedGoals()
        }
    }

    func configure() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = logOutButton
        navigationItem.title = "Home"
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .userLoggedOut:
                    self?.coordinator?.userLoggedOut()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(errorMessage: errorMessage)
    }

    @objc func logOutButtonTapped() {
        viewModel.logOut()
    }
}

extension HomeViewController: HomeViewDelegate {
    func homeViewDidSelectNewTextEntry() {
        coordinator?.presentNewTextEntryViewController()
    }
}
