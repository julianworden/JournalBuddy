//
//  LoginViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import Combine
import UIKit

class LoginViewController: UIViewController {
    weak var coordinator: OnboardingCoordinator?
    var viewModel = LoginViewModel()

    var cancellables = Set<AnyCancellable>()

    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = LoginView(viewModel: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        subscribeToPublishers()
    }

    func configure() {
        title = "Log In"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
    }

    func subscribeToPublishers() {
        viewModel.$loginSuccessful
            .sink { [weak self] loginSuccessful in
                guard loginSuccessful else { return }

                self?.coordinator?.userDidLogIn()
            }
            .store(in: &cancellables)
    }
}

//#Preview {
//    let navigationController = UINavigationController(rootViewController: LoginViewController())
//    navigationController.navigationBar.prefersLargeTitles = true
//    return navigationController
//}
