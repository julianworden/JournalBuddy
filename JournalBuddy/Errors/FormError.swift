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
    case textEntryIsEmpty
    case goalNameIsEmpty
    case textEntryHasNotBeenUpdated

    var errorDescription: String? {
        switch self {
        case .emailAddressesDoNotMatchOnSignUp:
            return "The email addresses you entered do not match, please try again."
        case .passwordsDoNotMatchOnSignUp:
            return "The passwords you entered do not match, please try again."
        case .textEntryIsEmpty:
            return "You cannot save an empty text entry, please try again after entering text."
        case .goalNameIsEmpty:
            return "You cannot save your goal without a name. Please enter a name and try again."
        case .textEntryHasNotBeenUpdated:
            return "You have not changed this text entry, so there is no need to update it."
        }
    }
}
