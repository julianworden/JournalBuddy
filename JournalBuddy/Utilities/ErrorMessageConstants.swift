//
//  ErrorMessageConstants.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

/// A set of error messages for use with print statements during development.
enum ErrorMessageConstants {
    case unexpectedTextFieldTagFound(tag: Int)
    case unexpectedViewState(viewState: ViewState)

    var description: String {
        switch self {
        case .unexpectedTextFieldTagFound(let tag):
            return "❌ Unexpected text field tag received: \(tag)"
        case .unexpectedViewState(viewState: let viewState):
            return "❌ Unexpected view state: \(viewState)"
        }
    }
}
