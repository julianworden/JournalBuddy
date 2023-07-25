//
//  MainTextFieldType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import UIKit

enum MainTextFieldType {
    case emailAddress, confirmEmailAddress, password, confirmPassword

    var keyboardType: UIKeyboardType {
        switch self {
        case .emailAddress, .confirmEmailAddress:
            return .emailAddress
        case .password, .confirmPassword:
            return .default
        }
    }

    var isSecureTextEntry: Bool {
        switch self {
        case .emailAddress, .confirmEmailAddress:
            return false
        case .password, .confirmPassword:
            return true
        }
    }

    var tag: Int {
        switch self {
        case .emailAddress:
            return 1
        case .confirmEmailAddress:
            return 2
        case .password:
            return 3
        case .confirmPassword:
            return 4
        }
    }

    var placeholder: String {
        switch self {
        case .emailAddress:
            return "Email Address"
        case .confirmEmailAddress:
            return "Confirm Email Address"
        case .password:
            return "Password"
        case .confirmPassword:
            return "Confirm Password"
        }
    }
}
