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
            passwordTextField,
            confirmPasswordTextField,
            signUpButton
        ]
    )
    private lazy var emailAddressTextField = MainTextField(
        keyboardType: .emailAddress,
        isSecureTextEntry: false,
        placeholder: "Email Address"
    )
    private lazy var confirmEmailAddressTextField = MainTextField(
        keyboardType: .emailAddress,
        isSecureTextEntry: false,
        placeholder: "Confirm Email Address"
    )
    private lazy var passwordTextField = MainTextField(
        keyboardType: .default,
        isSecureTextEntry: true,
        placeholder: "Password"
    )
    private lazy var confirmPasswordTextField = MainTextField(
        keyboardType: .default,
        isSecureTextEntry: true,
        placeholder: "Confirm Password"
    )
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
        backgroundColor = .systemBackground

        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.distribution = .fillEqually
        mainScrollViewContentStack.spacing = UIConstants.mainStackViewSpacing
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true
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

            emailAddressTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .displayingView:
                    self?.configureDefaultViewState()
                }
            }
            .store(in: &cancellables)
    }
}
