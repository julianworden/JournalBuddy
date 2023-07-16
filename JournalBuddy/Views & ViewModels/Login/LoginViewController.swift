//
//  LoginViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import UIKit

class LoginViewController: UIViewController {
    var viewModel = LoginViewModel()

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
    }

    func configure() {
        title = "Log In"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
    }
}

//#Preview {
//    let navigationController = UINavigationController(rootViewController: LoginViewController())
//    navigationController.navigationBar.prefersLargeTitles = true
//    return navigationController
//}
