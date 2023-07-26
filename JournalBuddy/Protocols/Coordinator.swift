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
    @MainActor func removeChildCoordinator(_ childCoordinator: Coordinator)
    @MainActor func viewController(_ viewController: UIViewController, shouldPresentErrorMessage message: String)
}
