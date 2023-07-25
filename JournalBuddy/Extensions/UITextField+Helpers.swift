//
//  UITextField+animateBorderColor.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import UIKit

extension UITextField {
    /// Changes the `borderColor` of a given text field with an animation. Designed to be used with `MainTextField`, but extending `UITextField` is easier
    /// than extending `MainTextField` because this method is usually used with `UITextFieldDelegate` methods.
    /// - Parameter color: The color to which the `borderColor` is to change.
    func animateBorderColorChange(newColor color: CGColor) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layer.borderColor = color
        }
    }

    /// A helper method for making it easier to work with the `textField(_:shouldChangeCharactersIn:replacementString:)` method in
    /// `UITextFieldDelegate`. That method's `textField` parameter does not contain the latest text update, so this method helps put together
    /// the delegate method's other parameters to create the most up-to-date text.
    /// - Parameters:
    ///   - newStringRange: The range where the `newString` should be inserted.
    ///   - newString: The latest text that was either just copied and pasted or typed. When the user types, this value only contain 1 character. It
    ///   can contain more than 1 character if the user copied and pasted something.
    /// - Returns: `self`'s latest text, including the `newString` which was inserted at the `newStringRange`.
    func getTextFieldTextAfterUpdate(newStringRange range: NSRange, newString: String) -> String {
        let textFieldTextAsNSString = NSString(string: self.text ?? "")
        let textAfterUpdate = textFieldTextAsNSString.replacingCharacters(in: range, with: newString)
        return textAfterUpdate
    }
}
