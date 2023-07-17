//
//  LoginView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import Combine
import UIKit

class LoginView: UIView, MainView {
    private lazy var logInStack = UIStackView(arrangedSubviews: [emailAddressTextField, passwordTextFieldStack])
    private lazy var emailAddressTextField = MainTextField(
        keyboardType: .emailAddress,
        isSecureTextEntry: false,
        placeholder: "Email Address"
    )

    private lazy var passwordTextFieldStack = UIStackView(arrangedSubviews: [passwordTextField, passwordEyeButton])
    private lazy var passwordTextField = MainTextField(
        keyboardType: .default,
        isSecureTextEntry: true,
        placeholder: "Password"
    )
    private lazy var passwordEyeButton = UIButton()
    private lazy var logInSignUpButtonStack = UIStackView(arrangedSubviews: [logInButton, signUpButton])
    private lazy var logInButton = PrimaryButton(title: "Log In")
    private lazy var signUpButton = PrimaryButton(title: "Sign Up")

    let viewModel: LoginViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configure()
        makeAccessible()
        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        logInStack.axis = .vertical
        logInStack.distribution = .fillEqually
        logInStack.spacing = 20
        logInStack.layoutMargins = UiConstants.mainVerticalStackLayoutMargins
        logInStack.isLayoutMarginsRelativeArrangement = true

        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)

        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)

        emailAddressTextField.delegate = self
        emailAddressTextField.addTarget(self, action: #selector(emailAddressTextFieldEdited), for: .editingChanged)

        passwordTextFieldStack.spacing = 5

        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldEdited), for: .editingChanged)

        passwordEyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        passwordEyeButton.tintColor = .systemOrange
        passwordEyeButton.addTarget(self, action: #selector(passwordEyeButtonTapped), for: .touchUpInside)

        logInSignUpButtonStack.axis = .vertical
        logInSignUpButtonStack.spacing = 20
        logInSignUpButtonStack.layoutMargins = UiConstants.mainVerticalStackLayoutMargins
        logInSignUpButtonStack.isLayoutMarginsRelativeArrangement = true
    }

    func makeAccessible() {

    }

    #warning("Move this to LoginViewController")
    func subscribeToPublishers() {
        
    }

    func constrain() {
        addConstrainedSubviews(logInStack, logInSignUpButtonStack)

        NSLayoutConstraint.activate([
            logInStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 7),
            logInStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            logInStack.trailingAnchor.constraint(equalTo: trailingAnchor),

            emailAddressTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 46),

            logInSignUpButtonStack.topAnchor.constraint(equalTo: logInStack.bottomAnchor, constant: 20),
            logInSignUpButtonStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            logInSignUpButtonStack.trailingAnchor.constraint(equalTo: trailingAnchor),

            logInButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 46),
            signUpButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
    }

    func showError(_ error: Error) {

    }

    @objc func emailAddressTextFieldEdited(_ textField: UITextField) {
        viewModel.emailAddress = textField.text ?? ""
    }

    @objc func passwordEyeButtonTapped() {
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false
            passwordEyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = true
            passwordEyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }

    @objc func passwordTextFieldEdited(_ textField: UITextField) {
        viewModel.password = textField.text ?? ""
    }

    @objc func logInButtonTapped() {
        viewModel.logIn()
    }

    @objc func signUpButtonTapped() {

    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField === emailAddressTextField {
            viewModel.emailAddress.removeAll()
        } else if textField === passwordTextField {
            viewModel.password.removeAll()
        } else {
            print("Unknown UITextField should clear.")
        }

        return true
    }
}
