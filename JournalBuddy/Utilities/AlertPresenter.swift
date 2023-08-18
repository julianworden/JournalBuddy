//
//  AlertPresenter.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

import UIKit

struct AlertPresenter {
    static func presentBasicErrorAlert(on viewController: UIViewController, errorMessage: String) {
        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let currentRootView = currentUIWindow.rootViewController?.view else { return }

        let alertToDisplay = CustomAlert(title: "Error", message: errorMessage, type: .error)

        present(alertToDisplay, on: currentRootView)
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

    private static func present(_ alertToDisplay: CustomAlert, on currentRootView: UIView) {
        currentRootView.addConstrainedSubview(alertToDisplay)

        NSLayoutConstraint.activate([
            alertToDisplay.topAnchor.constraint(equalTo: currentRootView.topAnchor),
            alertToDisplay.bottomAnchor.constraint(equalTo: currentRootView.bottomAnchor),
            alertToDisplay.leadingAnchor.constraint(equalTo: currentRootView.leadingAnchor),
            alertToDisplay.trailingAnchor.constraint(equalTo: currentRootView.trailingAnchor)
        ])

        UIView.animate(withDuration: 0.25) {
            alertToDisplay.alpha = 1
            alertToDisplay.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
