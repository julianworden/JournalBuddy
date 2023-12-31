//
//  FBAuthError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/20/23.
//

import Foundation

enum FBAuthError: LocalizedError {
    case invalidEmailAddress
    case emailAlreadyInUseOnSignUp
    case invalidPasswordOnSignUp
    case networkError
    case wrongPasswordOnLogIn
    case userNotFoundOnLogIn
    case userNotCreatedSuccessfully

    var errorDescription: String? {
        switch self {
        case .invalidEmailAddress:
            return "Please enter a valid email address."
        case .emailAlreadyInUseOnSignUp:
            return "This email is already registered to an existing account. Please go back to reset your password or sign in."
        case .invalidPasswordOnSignUp:
            return "Please enter a valid password. It must contain at least 6 characters."
        case .networkError:
            return "Please make sure you have a stable internet connection."
        case .wrongPasswordOnLogIn:
            return "Incorrect email or password. Please try again."
        case .userNotFoundOnLogIn:
            return "This email address is not registered with Journal Buddy. If you need to create a new account, use the Sign Up button."
        case .userNotCreatedSuccessfully:
            return "Something went wrong, your account was not created successfully. Please contact support."
        }
    }
}
