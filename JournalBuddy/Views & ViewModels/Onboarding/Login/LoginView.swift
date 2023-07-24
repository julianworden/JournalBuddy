//
//  LoginView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import Combine
import UIKit

class LoginView: UIView, MainView {
    private lazy var mainScrollView = UIScrollView()
    private lazy var mainScrollViewContentStack = UIStackView(arrangedSubviews: [logInStack, signUpStack])

    private lazy var logInStack = UIStackView(arrangedSubviews: [emailAddressTextField, passwordTextFieldStack, logInButton])
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
    private lazy var logInButton = PrimaryButton(title: "Log In")

    private lazy var signUpStack = UIStackView(arrangedSubviews: [dontHaveAnAccountLabel, signUpButton])
    private lazy var dontHaveAnAccountLabel = UILabel()
    private lazy var signUpButton = PrimaryButton(title: "Sign Up")

    let viewModel: LoginViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        subscribeToPublishers()
        makeAccessible()
        constrain()
    }

    override func layoutSubviews() {
        // Support very large Dynamic Type sizes

        if mainScrollView.contentSize.height > bounds.size.height {
            // User needs to scroll to see all content, don't add space between logInStack and signUpStack
            signUpStack.topAnchor.constraint(equalTo: logInStack.bottomAnchor).isActive = true
        } else {
            // User does not need to scroll to see all content, add space between logInStack and signUpStack
            signUpStack.bottomAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDefaultUI() {
        mainScrollView.showsVerticalScrollIndicator = false

        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.distribution = .equalCentering
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true

        logInStack.axis = .vertical
        logInStack.spacing = 20

        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)

        emailAddressTextField.delegate = self
        emailAddressTextField.addTarget(self, action: #selector(emailAddressTextFieldEdited), for: .editingChanged)

        passwordTextFieldStack.spacing = 5

        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldEdited), for: .editingChanged)

        passwordEyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        passwordEyeButton.addTarget(self, action: #selector(passwordEyeButtonTapped), for: .touchUpInside)

        signUpStack.axis = .vertical
        signUpStack.spacing = 7
        logInStack.setContentHuggingPriority(.defaultHigh, for: .vertical)

        dontHaveAnAccountLabel.text = "Don't have an account?"
        dontHaveAnAccountLabel.font = .preferredFont(forTextStyle: .body)
        dontHaveAnAccountLabel.numberOfLines = 0
        dontHaveAnAccountLabel.textAlignment = .center

        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }

    func disableButtonsAndTextFields() {
        emailAddressTextField.isEnabled = false
        passwordTextField.isEnabled = false
        passwordEyeButton.isEnabled = false
        logInButton.isEnabled = false
        signUpButton.isEnabled = false
    }

    func enableButtonsAndTextFields() {
        emailAddressTextField.isEnabled = true
        passwordTextField.isEnabled = true
        passwordEyeButton.isEnabled = true
        logInButton.isEnabled = true
        signUpButton.isEnabled = true
    }

    func makeAccessible() {
        dontHaveAnAccountLabel.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .displayingView:
                    self?.configureDefaultUI()
                case .loggingIn:
                    self?.disableButtonsAndTextFields()
                case .error(_):
                    self?.enableButtonsAndTextFields()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func constrain() {
        addConstrainedSubviews(mainScrollView)
        mainScrollView.addConstrainedSubview(mainScrollViewContentStack)

        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

            mainScrollViewContentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainScrollViewContentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainScrollViewContentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainScrollViewContentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            mainScrollViewContentStack.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),

            emailAddressTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 46),
            passwordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 46),
            logInButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 46),

            signUpButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
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
        print("I WANT TO SIGN UP")
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIConstants.mainTextFieldWithFocusBorderColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIConstants.mainTextFieldWithoutFocusBorderColor
        }
    }

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
