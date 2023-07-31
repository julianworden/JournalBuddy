//
//  StartupViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/31/23.
//

import UIKit

/// Used as the `rootViewController` on startup to prevent the app screen from going black while `SceneDelegate`'s
/// `scene(_:willConnectTo:options:)` performs asynchronous work to determine the app's state.
class StartupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
