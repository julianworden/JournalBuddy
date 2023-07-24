//
//  PasswordTextFieldStack.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import UIKit

class PasswordTextFieldStack: UIStackView {
    private lazy var passwordTextField = MainTextField(
        keyboardType: .default,
        isSecureTextEntry: true,
        placeholder: "Password"
    )
    private lazy var eyeButton = UIButton()

    weak var delegate: PasswordTextFieldStackDelegate?

    init(delegate: PasswordTextFieldStackDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)

        spacing = 5

        passwordTextField.delegate = self
        passwordTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldEdited), for: .editingChanged)

        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.addTarget(self, action: #selector(passwordEyeButtonTapped), for: .touchUpInside)

        addArrangedSubview(passwordTextField)
        addArrangedSubview(eyeButton)

        constrain()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func disableTextFieldAndButton() {
        passwordTextField.isEnabled = false
        eyeButton.isEnabled = false
    }

    func enableTextFieldAndButton() {
        passwordTextField.isEnabled = true
        eyeButton.isEnabled = true
    }

    func constrain() {
        passwordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
    }

    @objc func passwordTextFieldEdited(_ textField: UITextField) {
        delegate?.passwordTextFieldWasEdited(textFieldText: textField.text ?? "")
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

extension PasswordTextFieldStack: UITextFieldDelegate {
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
}
