//
//  Coordinator.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/17/23.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }

    func start()
    func removeChildCoordinator(_ childCoordinator: Coordinator)
}
