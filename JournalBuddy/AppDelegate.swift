//
//  AppDelegate.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import AVFoundation
import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        configureAudioSession()
        return true
    }
 
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            try audioSession.setCategory(.playAndRecord)
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch {
            print("❌ Failed to set up audio session.")
            print(error.emojiMessage)
        }
    }
}
