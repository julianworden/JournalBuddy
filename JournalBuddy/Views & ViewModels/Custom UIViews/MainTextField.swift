//
//  MainTextField.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

class MainTextField: UITextField {
    /// Uses `clearButtonRect(forBounds:)` to determine the rect for all text in text field. Prevents text from going underneath clear button.
    var textInsets: UIEdgeInsets {
        let clearButtonRect = clearButtonRect(forBounds: bounds)
        let clearButtonWidth = clearButtonRect.width
        return UIEdgeInsets(top: 0, left: 7, bottom: 0, right: clearButtonWidth + 7)
    }

    convenience init(type: MainTextFieldType) {
        self.init(frame: .zero)

        self.keyboardType = type.keyboardType
        self.tag = type.tag
        self.placeholder = type.placeholder
        self.clearButtonMode = .whileEditing
        self.isSecureTextEntry = type.isSecureTextEntry
        self.font = .preferredFont(forTextStyle: .body)
        self.adjustsFontForContentSizeCategory = true
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIConstants.mainTextFieldWithoutFocusBorderColor
        self.layer.borderWidth = 1.5
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    // Applies correct padding for text that isn't currently being edited
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    // Applies correct padding for text that is currently being edited
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
}
