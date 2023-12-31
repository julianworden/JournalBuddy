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
    let viewModel: LoginViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: OnboardingCoordinator, viewModel: LoginViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

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
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .loggedIn(let currentUser):
                    self?.coordinator?.onboardingDidEnd(for: currentUser)
                case .error(let error):
                    self?.showError(error)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ errorMessage: String) {
        coordinator?.presentErrorMessage(errorMessage: errorMessage)
    }
}

extension LoginViewController: LoginViewDelegate {
    func loginViewDidTapSignUpButton() {
        coordinator?.loginViewDidTapSignUpButton()
    }
}

//#Preview {
//    let mainCoordinator = MainCoordinator(databaseService: DatabaseService(), authService: AuthService(), appWindow: nil)
//    let onboardingCoordinator = OnboardingCoordinator(navigationController: UINavigationController(), databaseService: DatabaseService(), authService: AuthService(), parentCoordinator: mainCoordinator, appWindow: nil)
//
//    let viewModel = LoginViewModel(databaseService: DatabaseService(), authService: AuthService())
//    let loginViewController = LoginViewController(coordinator: onboardingCoordinator, viewModel: viewModel)
//    let navigationController = MainNavigationController(rootViewController: loginViewController)
//    return navigationController
//}
