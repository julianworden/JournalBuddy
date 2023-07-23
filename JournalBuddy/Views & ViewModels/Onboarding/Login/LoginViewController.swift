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

                self?.coordinator?.userDidLogIn()
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

//#Preview {
//    let navigationController = UINavigationController(rootViewController: LoginViewController())
//    navigationController.navigationBar.prefersLargeTitles = true
//    return navigationController
//}
