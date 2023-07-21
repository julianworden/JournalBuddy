//
//  FBAuthError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/20/23.
//

import Foundation

enum FBAuthError: LocalizedError {
    case invalidEmailAddress
    case networkError
    case wrongPasswordOnLogIn
    case userNotFoundOnLogIn
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidEmailAddress:
            return "Please enter a valid email address."
        case .networkError:
            return "Please make sure you have a stable internet connection."
        case .wrongPasswordOnLogIn:
            return "Incorrect email or password. Please try again."
        case .userNotFoundOnLogIn:
            return "This email address is not registered with Journal Buddy. If you need to create a new account, use the Sign Up button."
        case .unknown(let error):
            return "An unknown error occurred, please try again. System Error: \(error.localizedDescription)"
        }
    }
}
