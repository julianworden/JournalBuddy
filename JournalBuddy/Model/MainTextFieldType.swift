//
//  MainTextFieldType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import UIKit

enum MainTextFieldType {
    case emailAddress
    case confirmEmailAddress
    case password
    case confirmPassword
    case name

    var keyboardType: UIKeyboardType {
        switch self {
        case .emailAddress, .confirmEmailAddress:
            return .emailAddress
        case .password, .confirmPassword, .name:
            return .default
        }
    }

    var isSecureTextEntry: Bool {
        switch self {
        case .password, .confirmPassword:
            return true
        default:
            return false
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
        case .name:
            return 5
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
        case .name:
            return "Name"
        }
    }
}
