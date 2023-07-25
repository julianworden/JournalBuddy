//
//  ErrorMessageConstants.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

/// A set of error messages for use with print statements during development.
enum ErrorMessageConstants {
    case mainCoordinatorMissingNavigationController
    case unexpectedTextFieldTagFound(tag: Int)
    case unexpectedViewState(viewState: ViewState)

    var description: String {
        switch self {
        case .mainCoordinatorMissingNavigationController:
            return "❌ MainCoordinator called a method that requires a navigation controller, but the method could not find one."
        case .unexpectedTextFieldTagFound(let tag):
            return "❌ Unexpected text field tag received: \(tag)"
        case .unexpectedViewState(viewState: let viewState):
            return "❌ Unexpected view state: \(viewState)"
        }
    }
}
