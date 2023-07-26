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
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .emailAddressesDoNotMatchOnSignUp:
            return "The email addresses you entered do not match, please try again."
        case .passwordsDoNotMatchOnSignUp:
            return "The passwords you entered do not match, please try again."
        case .unknown(let errorMessage):
            return "An unknown error occurred, please try again. System Error: \(errorMessage)"
        }
    }
}
