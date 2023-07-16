//
//  MainTextField.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

class MainTextField: UITextField {
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let x = bounds.maxX - 70
        let y = bounds.size.height / 2 - 30 / 2
        return CGRect(x: x, y: y, width: 60, height: 30)
    }
}
