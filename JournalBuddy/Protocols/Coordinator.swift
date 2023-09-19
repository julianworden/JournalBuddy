//
//  Coordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

protocol Coordinator: AnyObject {
    @MainActor var childCoordinators: [Coordinator] { get set }
    @MainActor var databaseService: DatabaseServiceProtocol { get }
    @MainActor var authService: AuthServiceProtocol { get }

    @MainActor func start()
    @MainActor func removeChildCoordinator(_ childCoordinator: Coordinator?)
    /// Establishes the logic for presenting the user with an error message, optionally attaching the error message directly to
    /// a view controller as opposed to the current `UIWindow`'s root view controller's view.
    /// - Parameters:
    ///   - viewController: The view controller to which the error alert should be attached. This value is usually only not nil if
    ///   an alert needs to be presented on a sheet. If this value is nil, then the alert will be presented on the current `UIWindow`'s
    ///   root view controller's view, which doesn't work for sheets because it causes the alert to be rendered behind the sheet.
    ///   - errorMessage: The error message that the user should see in the alert.
    @MainActor func presentErrorMessage(
        onViewController viewController: UIViewController?,
        errorMessage: String
    )
}
