//
//  MainNavigationController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/6/23.
//

import UIKit

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        navigationBar.prefersLargeTitles = true
        navigationBar.maximumContentSizeCategory = .extraLarge

        let navigationBarAppearance = UINavigationBarAppearance()
        let navigationBarItemAppearance = UIBarButtonItemAppearance()
        let inlineTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryElement, .font: UIFont.avenirNextBoldBody]
        let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryElement, .font: UIFont.avenirNextBoldLargeTitle]
        let navigationBarItemAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.avenirNextRegularBody]

        navigationBarItemAppearance.normal.titleTextAttributes = navigationBarItemAttributes
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.shadowColor = nil
        navigationBarAppearance.titleTextAttributes = inlineTitleTextAttributes
        navigationBarAppearance.largeTitleTextAttributes = largeTitleTextAttributes
        navigationBarAppearance.backButtonAppearance = navigationBarItemAppearance
        navigationBarAppearance.buttonAppearance = navigationBarItemAppearance

        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.scrollEdgeAppearance = navigationBarAppearance

        navigationBar.setTitleVerticalPositionAdjustment(10, for: .compact)
    }
}
