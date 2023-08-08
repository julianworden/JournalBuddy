//
//  MainNavigationController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/6/23.
//

import Combine
import UIKit

class MainNavigationController: UINavigationController {
    let navigationBarAppearance = UINavigationBarAppearance()
    let navigationBarItemAppearance = UIBarButtonItemAppearance()
    let inlineTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryElement, .font: UIFontMetrics.avenirNextBoldBody]
    let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryElement, .font: UIFontMetrics.avenirNextBoldLargeTitle]
    let navigationBarItemAttributes: [NSAttributedString.Key: Any] = [.font: UIFontMetrics.avenirNextRegularBody]

    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        navigationBar.prefersLargeTitles = true
        
        navigationBarItemAppearance.normal.titleTextAttributes = navigationBarItemAttributes
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.shadowColor = nil
        navigationBarAppearance.titleTextAttributes = inlineTitleTextAttributes
        navigationBarAppearance.largeTitleTextAttributes = largeTitleTextAttributes
        navigationBarAppearance.backButtonAppearance = navigationBarItemAppearance
        navigationBarAppearance.buttonAppearance = navigationBarItemAppearance
        
        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
}
