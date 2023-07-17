//
//  MainTextField.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

class PasswordTextField: UITextField {
    convenience init(rightView: UIView?) {
        self.init(frame: .zero)

        self.keyboardType = .default
        self.isSecureTextEntry = true
        self.placeholder = "Password"
        self.borderStyle = .roundedRect
        self.rightView = rightView
        self.rightView?.isHidden = true
        self.rightViewMode = .always
        self.font = .preferredFont(forTextStyle: .body)
        self.adjustsFontForContentSizeCategory = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let x = bounds.maxX - 70
        let y = bounds.size.height / 2 - 30 / 2
        return CGRect(x: x, y: y, width: 60, height: 30)
    }
}
