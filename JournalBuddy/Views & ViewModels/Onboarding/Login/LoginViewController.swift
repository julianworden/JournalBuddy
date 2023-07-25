//
//  LoginViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import Combine
import UIKit

class LoginViewController: UIViewController, MainViewController {
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
        view = LoginView(viewModel: viewModel, delegate: self)
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
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .error(let error):
                    self?.showError(error)
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.$loginSuccessful
            .sink { [weak self] loginSuccessful in
                guard loginSuccessful else { return }

                self?.coordinator?.onboardingDidEnd()
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {
        coordinator?.viewController(self, shouldPresentError: error)
    }
}

extension LoginViewController: LoginViewDelegate {
    func loginViewDidTapSignUpButton() {
        coordinator?.loginViewDidTapSignUpButton()
    }
}

//#Preview {
//    let navigationController = UINavigationController(rootViewController: LoginViewController())
//    navigationController.navigationBar.prefersLargeTitles = true
//    return navigationController
//}
