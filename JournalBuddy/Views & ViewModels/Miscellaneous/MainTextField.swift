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
        self.borderStyle = .roundedRect
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
}
