//
//  CustomError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

import Foundation

enum CustomError: LocalizedError {
    case emailAddressesDoNotMatchOnSignUp
    case passwordsDoNotMatchOnSignUp

    var errorDescription: String? {
        switch self {
        case .emailAddressesDoNotMatchOnSignUp:
            return "The email addresses you entered do not match, please try again."
        case .passwordsDoNotMatchOnSignUp:
            return "The passwords you entered do not match, please try again."
        }
    }
}
