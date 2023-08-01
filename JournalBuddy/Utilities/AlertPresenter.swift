//
//  AlertPresenter.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

import UIKit

struct AlertPresenter {
    static func presentBasicErrorAlert(on viewController: UIViewController, errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        viewController.present(alertController, animated: true)
    }
    
    /// Presents a `UIAlertController` that confirms whether or not the user wants to perform a certain destruction action.
    /// - Parameters:
    ///   - viewController: The view controller that should present the alert.
    ///   - message: The message that is to be shown in the alert.
    ///   - confirmedWork: The work to perform if the user confirms that they want to perform the destruction action in question.
    static func presentDestructiveConfirmationAlert(
        on viewController: UIViewController,
        message: String,
        confirmedWork: @escaping () async -> Void
    ) {
        let alertController = UIAlertController(title: "Are You Sure?", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            Task {
                await confirmedWork()
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)

        viewController.present(alertController, animated: true)
    }
}
