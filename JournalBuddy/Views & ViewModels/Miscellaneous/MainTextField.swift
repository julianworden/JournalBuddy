//
//  MainTextField.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

class MainTextField: UITextField {
    convenience init(keyboardType: UIKeyboardType, isSecureTextEntry: Bool, placeholder: String) {
        self.init(frame: .zero)

        self.keyboardType = keyboardType
        self.placeholder = placeholder
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIConstants.mainTextFieldWithoutFocusBorderColor
        self.layer.borderWidth = 1.5
        self.clearButtonMode = .whileEditing
        self.isSecureTextEntry = isSecureTextEntry
        self.font = .preferredFont(forTextStyle: .body)
        self.adjustsFontForContentSizeCategory = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIConstants.mainTextFieldTextInsets)
    }

    // Applies correct padding for text that isn't currently being edited
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIConstants.mainTextFieldTextInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIConstants.mainTextFieldTextInsets)
    }
}
