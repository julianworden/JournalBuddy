//
//  UIButton.Configuration+back.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/7/23.
//

import UIKit

extension UIButton.Configuration {
    static var back: UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        configuration.attributedTitle = AttributedString("Back", attributes: AttributeContainer([.font: UIFontMetrics.avenirNextRegularBody]))
        configuration.imagePadding = 5
        return configuration
    }
}
