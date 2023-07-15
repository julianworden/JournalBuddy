//
//  HomeSquareButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/13/23.
//

import UIKit

class HomeSquareButton: UIButton {
    private lazy var homeSquareButtonType = HomeSquareButtonType.text
    private lazy var content = HomeNewEntryCard(type: homeSquareButtonType)

    convenience init(homeSquareButtonType: HomeSquareButtonType) {
        self.init(type: .custom)
        self.homeSquareButtonType = homeSquareButtonType

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
