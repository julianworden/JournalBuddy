//
//  UIConstants.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

enum UIConstants {
    // MARK: - UIStackView

    /// The `UIEdgeInsets` on the leading and trailing edge of a stack view that fills the entire width of a `MainView`.
    static let mainStackViewLeadingAndTrailingLayoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    static let mainStackViewSpacing: CGFloat = 20
    /// The minimum height of an element in a stack view that is being used as a form. For instance, this is the minimum height of a text field in `LoginView`.
    static let mainStackViewMinimumFormElementHeight: CGFloat = 46

    // MARK: - UIView

    /// The amount of padding on the leading edge of a `UIView` that fills the entire width of a `MainView`.
    static let mainViewLeadingPadding: CGFloat = 15
    /// The amount of padding on the trailing edge of a `UIView` that fills the entire width of a `MainView`.
    static let mainViewTrailingPadding: CGFloat = -15

    // MARK: - UIButton

    static let normalOrangeButtonBackgroundColor = UIColor.systemOrange
    static let disabledOrangeButtonBackgroundColor = UIColor.systemOrange.withAlphaComponent(0.3)

    // MARK: - UITextField

    /// The amount of padding to apply to all text rects in `MainTextField`.
    static let mainTextFieldTextInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
    /// The `borderColor` of a `MainTextField` that is not currently being edited.
    static let mainTextFieldWithoutFocusBorderColor = UIColor.systemGray5.cgColor
    /// The `borderColor` of a `MainTextField` that is currently being edited.
    static let mainTextFieldWithFocusBorderColor = UIColor.systemOrange.cgColor
}
