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

        configure(textFieldType: type)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(textFieldType: MainTextFieldType) {
        keyboardType = textFieldType.keyboardType
        tag = textFieldType.tag
        attributedPlaceholder = NSAttributedString(string: textFieldType.placeholder, attributes: [.foregroundColor: UIColor.textFieldPlaceholder])
        clearButtonMode = .whileEditing
        isSecureTextEntry = textFieldType.isSecureTextEntry
        font = UIFontMetrics.avenirNextRegularBody
        textColor = .primaryElement
        adjustsFontForContentSizeCategory = true
        layer.cornerRadius = 12
        layer.borderColor = UIColor.disabled.cgColor
        layer.borderWidth = 1.5
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
