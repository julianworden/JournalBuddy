//
//  LoginViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import Combine
import UIKit

class LoginViewController: UIViewController {
    var viewModel = LoginViewModel()

    var cancellables = Set<AnyCancellable>()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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

                let homeViewController = HomeViewController()
                let navigationController = UINavigationController(rootViewController: homeViewController)
                navigationController.navigationBar.prefersLargeTitles = true
                self?.view.window?.rootViewController = navigationController
                self?.view.window?.makeKeyAndVisible()
            }
            .store(in: &cancellables)
    }
}

//#Preview {
//    let navigationController = UINavigationController(rootViewController: LoginViewController())
//    navigationController.navigationBar.prefersLargeTitles = true
//    return navigationController
//}
