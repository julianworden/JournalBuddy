//
//  PasswordTextFieldStack.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import UIKit

class PasswordTextFieldStack: UIStackView {
    private lazy var passwordTextField = MainTextField(type: textFieldType)
    private lazy var eyeButton = UIButton()

    let textFieldType: MainTextFieldType
    weak var delegate: UITextFieldDelegate?

    /// Uses a delegate and a tag to create a horizontal `UIStackView` that shows both a `MainTextField` and an eye button whenever a user is asked to provide their password.
    /// - Parameters:
    ///   - delegate: The object responsible for reporting `passwordTextField` changes to a `MainViewModel`.
    ///   This is usually the `MainView` displaying the `PasswordTextFieldStack`.
    ///   - textFieldType: `passwordTextField`'s type. It contains data that will determine `passwordTextField`'s tag, placeholder, and other data.
    init(delegate: UITextFieldDelegate?, textFieldType: MainTextFieldType) {
        self.delegate = delegate
        self.textFieldType = textFieldType

        super.init(frame: .zero)

        passwordTextField.delegate = delegate

        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        // Prevent text field from expanding and pushing button off screen with long passwords
        eyeButton.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        // Prevent eye button from expanding to fill space, instead of having the text field expand to fill space.
        eyeButton.setContentHuggingPriority(UILayoutPriority(751), for: .horizontal)
        eyeButton.addTarget(self, action: #selector(passwordEyeButtonTapped), for: .touchUpInside)

        spacing = 5
        addArrangedSubview(passwordTextField)
        addArrangedSubview(eyeButton)

        constrain()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Disables interaction when the `MainView` displaying the `PasswordTextFieldStack` is performing an asynchronous task.
    func disableTextFieldAndButton() {
        passwordTextField.isEnabled = false
        eyeButton.isEnabled = false
    }

    /// Re-enables interaction when the `MainView` displaying the `PasswordTextFieldStack` is done performing an asynchronous task.
    func enableTextFieldAndButton() {
        passwordTextField.isEnabled = true
        eyeButton.isEnabled = true
    }

    func constrain() {
        passwordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight).isActive = true
    }


    @objc func passwordEyeButtonTapped() {
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = true
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
}
