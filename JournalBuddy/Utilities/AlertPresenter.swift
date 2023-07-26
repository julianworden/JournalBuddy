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
}
