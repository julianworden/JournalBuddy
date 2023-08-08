//
//  UIFontMetrics+Helpers.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/8/23.
//

import UIKit

extension UIFontMetrics {
    static var avenirNextBoldLargeTitle: UIFont {
        UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .avenirNextBoldLargeTitle)
    }

    static var avenirNextBoldTitle2: UIFont {
        UIFontMetrics(forTextStyle: .title2).scaledFont(for: .avenirNextBoldTitle2)
    }

    static var avenirNextBoldBody: UIFont {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: .avenirNextBoldBody)
    }

    static var avenirNextRegularBody: UIFont {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: .avenirNextRegularBody)
    }
}
