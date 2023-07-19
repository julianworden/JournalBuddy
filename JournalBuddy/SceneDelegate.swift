//
//  SceneDelegate.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var mainCoordinator: MainCoordinator?
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        mainCoordinator = MainCoordinator(navigationController: navigationController, appWindow: window)
        mainCoordinator?.start()
    }
}

