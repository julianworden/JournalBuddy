//
//  SignUpView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import Combine
import UIKit

class SignUpView: UIView, MainView {
    private lazy var mainScrollView = UIScrollView()
    private lazy var mainScrollViewContentStack = UIStackView(
        arrangedSubviews: [
            emailAddressTextField,
            confirmEmailAddressTextField,
            passwordTextFieldStack,
            confirmPasswordTextFieldStack,
            signUpButton
        ]
    )
    private lazy var emailAddressTextField = MainTextField(type: .emailAddress)
    private lazy var confirmEmailAddressTextField = MainTextField(type: .confirmEmailAddress)
    private lazy var passwordTextFieldStack = PasswordTextFieldStack(delegate: self, textFieldType: .password)
    private lazy var confirmPasswordTextFieldStack = PasswordTextFieldStack(delegate: self, textFieldType: .confirmPassword)
    private lazy var signUpButton = PrimaryButton(title: "Sign Up")

    let viewModel: SignUpViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDefaultViewState() {
        backgroundColor = .background

        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.spacing = UIConstants.mainStackViewSpacing
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true

        emailAddressTextField.delegate = self
        confirmEmailAddressTextField.delegate = self

        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGestureRecognizer)
    }

    func constrain() {
        addConstrainedSubview(mainScrollView)
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
            confirmEmailAddressTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight),
            signUpButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight)
        ])
    }

    func makeAccessible() {
        emailAddressTextField.adjustsFontForContentSizeCategory = true
        confirmEmailAddressTextField.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .displayingView:
                    self?.configureDefaultViewState()
                case .creatingAccount:
                    self?.disableTextFieldsAndButtons()
                case .error(_):
                    self?.enableTextFieldsAndButton()
                default:
                    print(ErrorMessageConstants.unexpectedViewState(viewState: viewState))
                }
            }
            .store(in: &cancellables)
    }

    func disableTextFieldsAndButtons() {
        emailAddressTextField.isEnabled = false
        confirmEmailAddressTextField.isEnabled = false
        passwordTextFieldStack.disableTextFieldAndButton()
        confirmPasswordTextFieldStack.disableTextFieldAndButton()
        signUpButton.isEnabled = false
    }

    func enableTextFieldsAndButton() {
        emailAddressTextField.isEnabled = true
        confirmEmailAddressTextField.isEnabled = true
        passwordTextFieldStack.enableTextFieldAndButton()
        confirmPasswordTextFieldStack.enableTextFieldAndButton()
        signUpButton.isEnabled = true
    }

    @objc func signUpButtonTapped() {
        Task {
            await viewModel.signUpButtonTapped()
        }
    }

    @objc func dismissKeyboard() {
        emailAddressTextField.resignFirstResponder()
        confirmEmailAddressTextField.resignFirstResponder()
        passwordTextFieldStack.resignTextFieldFirstResponder()
        confirmPasswordTextFieldStack.resignTextFieldFirstResponder()
    }
}

extension SignUpView: UITextFieldDelegate {
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
        case MainTextFieldType.confirmEmailAddress.tag:
            viewModel.confirmedEmailAddress = textFieldTextAfterUpdate
        case MainTextFieldType.password.tag:
            viewModel.password = textFieldTextAfterUpdate
        case MainTextFieldType.confirmPassword.tag:
            viewModel.confirmedPassword = textFieldTextAfterUpdate
        default:
            print(ErrorMessageConstants.unexpectedTextFieldTagFound(tag: tag))
        }

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case MainTextFieldType.emailAddress.tag:
            viewModel.emailAddress.removeAll()
        case MainTextFieldType.confirmEmailAddress.tag:
            viewModel.confirmedEmailAddress.removeAll()
        case MainTextFieldType.password.tag:
            viewModel.password.removeAll()
        case MainTextFieldType.confirmPassword.tag:
            viewModel.confirmedPassword.removeAll()
        default:
            print(ErrorMessageConstants.unexpectedTextFieldTagFound(tag: tag))
        }

        return true
    }
}
