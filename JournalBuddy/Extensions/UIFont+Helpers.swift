//
//  UIFont+boldLargeTitle.swift
//  WatchaGot
//
//  Created by Julian Worden on 7/5/23.
//

import UIKit

// TODO: Convert this to a UIFontMetrics extension instead.
extension UIFont {
    static var boldLargeTitle: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }

    static var boldTitle2: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
    }

    static var boldTitle3: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
    }

    static var boldBody: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
    }

    static var avenirNextBoldLargeTitle: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: 34) ?? .boldLargeTitle
    }

    static var avenirNextBoldTitle2: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: 22) ?? .boldTitle2
    }

    static var avenirNextBoldBody: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIFont.labelFontSize) ?? .boldBody
    }

    static var avenirNextRegularBody: UIFont {
        UIFont(name: FontConstants.avenirNextRegular, size: UIFont.labelFontSize) ?? .preferredFont(forTextStyle: .body)
    }
}
