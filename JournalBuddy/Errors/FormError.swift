//
//  FormError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/27/23.
//

import Foundation

enum FormError: LocalizedError {
    case emailAddressesDoNotMatchOnSignUp
    case passwordsDoNotMatchOnSignUp
    case emptyTextEntry

    var errorDescription: String? {
        switch self {
        case .emailAddressesDoNotMatchOnSignUp:
            return "The email addresses you entered do not match, please try again."
        case .passwordsDoNotMatchOnSignUp:
            return "The passwords you entered do not match, please try again."
        case .emptyTextEntry:
            return "You cannot save an empty text entry, please try again after entering text."
        }
    }
}
