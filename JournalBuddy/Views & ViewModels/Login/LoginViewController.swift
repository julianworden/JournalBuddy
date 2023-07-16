//
//  LoginViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/15/23.
//

import Combine
import UIKit

class LoginViewController: UIViewController, MainViewController {
    private lazy var logInStack = UIStackView(arrangedSubviews: [emailAddressTextField, passwordTextField, logInButton, signUpButton])
    private lazy var emailAddressTextField = UITextField()
    private lazy var passwordTextField = MainTextField()
    private lazy var passwordTextFieldButtons = UIStackView(arrangedSubviews: [passwordEyeButton, clearButton])
    private lazy var passwordEyeButton = UIButton()
    private lazy var clearButton = UIButton()
    private lazy var logInButton = PrimaryButton(title: "Log In")
    private lazy var signUpButton = PrimaryButton(title: "Sign Up")

    var cancellables = Set<AnyCancellable>()

    var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        makeAccessible()
        constrain()
    }

    func configure() {
        title = "Log In"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground

        logInStack.axis = .vertical
        logInStack.spacing = 20
        logInStack.distribution = .fillEqually
        logInStack.layoutMargins = UiConstants.mainVerticalStackLayoutMargins
        logInStack.isLayoutMarginsRelativeArrangement = true

        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)

        emailAddressTextField.font = .preferredFont(forTextStyle: .body)
        emailAddressTextField.placeholder = "Email Address"
        emailAddressTextField.borderStyle = .roundedRect

        passwordTextField.font = .preferredFont(forTextStyle: .body)
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.clearButtonMode = .always
        passwordTextField.rightView = passwordTextFieldButtons
        passwordTextField.rightViewMode = .always

        passwordTextFieldButtons.spacing = 10

        passwordEyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        passwordEyeButton.tintColor = .orange

        clearButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        clearButton.tintColor = .orange
    }

    func makeAccessible() {
        emailAddressTextField.adjustsFontForContentSizeCategory = true
        passwordTextField.adjustsFontForContentSizeCategory = true
        logInButton.titleLabel?.adjustsFontForContentSizeCategory = true
        signUpButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {

    }

    func constrain() {
        view.addConstrainedSubviews(logInStack)

        NSLayoutConstraint.activate([
            logInStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            logInStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logInStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            emailAddressTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 46),

            clearButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
    
    func showError(_ error: Error) {

    }

    @objc func logInButtonTapped() {
        let homeViewModel = HomeViewModel()
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        view.window?.rootViewController = navigationController
        view.window?.makeKeyAndVisible()
    }
}

#Preview {
    let navigationController = UINavigationController(rootViewController: LoginViewController(viewModel: LoginViewModel()))
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
