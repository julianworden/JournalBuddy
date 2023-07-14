//
//  HomeNewEntryButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/13/23.
//

import UIKit

class HomeNewEntryButton: UIButton {
    private lazy var homeNewEntryButtonType = HomeNewEntryButtonType.text
    private lazy var content = HomeNewEntryCard(type: homeNewEntryButtonType)

    convenience init(homeNewEntryButtonType: HomeNewEntryButtonType) {
        self.init(type: .custom)
        self.homeNewEntryButtonType = homeNewEntryButtonType

        configure()
        constrain()
    }
    
    func configure() {
        content.isUserInteractionEnabled = false
    }

    func constrain() {
        addConstrainedSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
