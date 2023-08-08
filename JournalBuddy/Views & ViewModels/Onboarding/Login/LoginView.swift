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
    private lazy var emailAddressTextField = MainTextField(type: .emailAddress)
    private lazy var passwordTextFieldStack = PasswordTextFieldStack(delegate: self, textFieldType: .password)
    private lazy var logInButton = PrimaryButton(title: "Log In")

    private lazy var signUpStack = UIStackView(arrangedSubviews: [dontHaveAnAccountLabel, signUpButton])
    private lazy var dontHaveAnAccountLabel = UILabel()
    private lazy var signUpButton = PrimaryButton(title: "Sign Up")

    weak var delegate: LoginViewDelegate?
    let viewModel: LoginViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: LoginViewModel, delegate: LoginViewDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate

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
            // User does not need to scroll to see all content, add space between logInStack and signUpStack by pinning signUpStack to the bottom of the view
            signUpStack.bottomAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDefaultViewState() {
        backgroundColor = UIColor.background

        mainScrollView.showsVerticalScrollIndicator = false

        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.distribution = .equalCentering
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true

        logInStack.axis = .vertical
        logInStack.spacing = UIConstants.mainStackViewSpacing

        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)

        emailAddressTextField.delegate = self
        emailAddressTextField.addTarget(self, action: #selector(emailAddressTextFieldEdited), for: .editingChanged)

        signUpStack.axis = .vertical
        signUpStack.spacing = 7

        dontHaveAnAccountLabel.text = "Don't have an account?"
        dontHaveAnAccountLabel.textColor = UIColor.primaryElement
        dontHaveAnAccountLabel.font = UIFontMetrics.avenirNextRegularBody
        dontHaveAnAccountLabel.numberOfLines = 0
        dontHaveAnAccountLabel.textAlignment = .center

        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }

    func disableButtonsAndTextFields() {
        emailAddressTextField.isEnabled = false
        passwordTextFieldStack.disableTextFieldAndButton()
        logInButton.isEnabled = false
        signUpButton.isEnabled = false
    }

    func enableButtonsAndTextFields() {
        emailAddressTextField.isEnabled = true
        passwordTextFieldStack.enableTextFieldAndButton()
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
                    self?.configureDefaultViewState()
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
            mainScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            mainScrollViewContentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainScrollViewContentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainScrollViewContentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainScrollViewContentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            mainScrollViewContentStack.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),

            emailAddressTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight),
            logInButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight),

            signUpButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight)
        ])
    }

    @objc func emailAddressTextFieldEdited(_ textField: UITextField) {
        viewModel.emailAddress = textField.text ?? ""
    }

    @objc func logInButtonTapped() {
        Task {
            await viewModel.logIn()
        }
    }

    @objc func signUpButtonTapped() {
        delegate?.loginViewDidTapSignUpButton()
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.animateBorderColorChange(newColor: UIColor.primaryElement.cgColor)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.animateBorderColorChange(newColor: UIColor.disabled.cgColor)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldTextAfterUpdate = textField.getTextFieldTextAfterUpdate(newStringRange: range, newString: string)

        switch textField.tag {
        case MainTextFieldType.emailAddress.tag:
            viewModel.emailAddress = textFieldTextAfterUpdate
        case MainTextFieldType.password.tag:
            viewModel.password = textFieldTextAfterUpdate
        default:
            print(ErrorMessageConstants.unexpectedTextFieldTagFound(tag: tag))
        }

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case MainTextFieldType.emailAddress.tag:
            viewModel.emailAddress.removeAll()
        case MainTextFieldType.password.tag:
            viewModel.password.removeAll()
        default:
            print(ErrorMessageConstants.unexpectedTextFieldTagFound(tag: tag))
        }

        return true
    }
}
