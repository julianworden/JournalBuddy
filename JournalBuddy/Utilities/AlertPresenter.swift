//
//  AlertPresenter.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

import UIKit

@MainActor
struct AlertPresenter {
    static func presentBasicErrorAlert(errorMessage: String) {
        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let currentRootView = currentUIWindow.rootViewController?.view else { return }

        let alertToDisplay = CustomAlert(
            title: "Error",
            message: errorMessage,
            dismissButtonText: "OK"
        )

        present(alertToDisplay, on: currentRootView)
    }

    /// Presents a `UIAlertController` that confirms whether or not the user wants to perform a certain destruction action.
    /// - Parameters:
    ///   - viewController: The view controller that should present the alert.
    ///   - message: The message that is to be shown in the alert.
    ///   - confirmedWork: The work to perform if the user confirms that they want to perform the destruction action in question.
    static func presentDestructiveConfirmationAlert(
        message: String,
        confirmedWork: @escaping () async -> Void
    ) {
        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let currentRootView = currentUIWindow.rootViewController?.view else { return }
        
        let alertToDisplay = CustomAlert(
            title: "Are You Sure?",
            message: message,
            dismissButtonText: "Cancel",
            primaryButtonText: "Yes",
            primaryButtonTextColor: .destructive,
            primaryAction: confirmedWork
        )

        present(alertToDisplay, on: currentRootView)
    }
    
    static func presentInadequatePermissionsAlert(on viewController: UIViewController, withMessage message: String) {
        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let currentRootView = currentUIWindow.rootViewController?.view else { return }
        
        
        let alertToDisplay = CustomAlert(
            title: "Error",
            message: message,
            dismissButtonText: "Cancel",
            dismissAction: { viewController.navigationController?.popViewController(animated: true) },
            primaryButtonText: "Settings",
            primaryButtonTextColor: .primaryElement,
            primaryAction: { await openSettingsURL(on: viewController) }
        )

        present(alertToDisplay, on: currentRootView)
    }
    
    private static func openSettingsURL(on viewController: UIViewController) async {
        let settingsURL = UIApplication.openSettingsURLString
        
        await UIApplication.shared.open(URL(string: settingsURL)!)
        viewController.navigationController?.popViewController(animated: true)
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
