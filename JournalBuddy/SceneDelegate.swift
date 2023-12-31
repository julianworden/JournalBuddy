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
        // Prevent screen from going black while the below Task is performed.
        window?.rootViewController = StartupViewController()
        window?.makeKeyAndVisible()

        Task {
            let authService = AuthService()
            let databaseService = DatabaseService(authService: authService)

            if let currentFirebaseAuthUser = authService.currentFirebaseAuthUser {
                do {
                    let currentUser = try await databaseService.getUser(withUID: currentFirebaseAuthUser.uid)
                    
                    mainCoordinator = MainCoordinator(
                        databaseService: databaseService,
                        authService: authService,
                        appWindow: window,
                        currentUser: currentUser
                    )
                    
                    mainCoordinator?.start()
                } catch {
                    print("❌ Failed to fetch current user's data.")
                    print(error.emojiMessage)
                }
            } else {
                mainCoordinator = MainCoordinator(
                    databaseService: databaseService,
                    authService: authService,
                    appWindow: window,
                    currentUser: nil
                )

                mainCoordinator?.start()
            }
        }
    }
}

