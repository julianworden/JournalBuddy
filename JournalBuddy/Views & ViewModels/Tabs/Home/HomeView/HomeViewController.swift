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
    weak var coordinator: HomeCoordinator?
    let viewModel: HomeViewModel
    var cancellables = Set<AnyCancellable>()

    // Temporary button for development
    private lazy var logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonTapped))

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

        configure()
        subscribeToPublishers()
    }

    func configure() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = logOutButton
        navigationItem.title = "Home"
    }

    func subscribeToPublishers() {
        viewModel.$userLoggedOut
            .sink { [weak self] userLoggedOut in
                guard userLoggedOut else { return }

                self?.coordinator?.userLoggedOut()
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {
        coordinator?.viewController(self, shouldPresentError: error)
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

//#Preview {
//    let navigationController = UINavigationController(rootViewController: HomeViewController())
//    navigationController.navigationBar.prefersLargeTitles = true
//    return navigationController
//}
