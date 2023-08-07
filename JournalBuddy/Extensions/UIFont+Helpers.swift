//
//  UIFont+boldLargeTitle.swift
//  WatchaGot
//
//  Created by Julian Worden on 7/5/23.
//

import UIKit

// TODO: Convert this to a UIFontMetrics extension instead.
extension UIFont {
    /// A convenient way to achieve a bold version of `UIFont.TextStyle.largeTitle`. Designed to be used in conjunction with
    /// `UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont.boldLargeTitle)` for easier Dynamic Type support.
    static var boldLargeTitle: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }

    /// A convenient way to achieve a bold version of `UIFont.TextStyle.title2`. Designed to be used in conjunction with
    /// `UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.boldTitle2)` for easier Dynamic Type support.
    static var boldTitle2: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
    }

    /// A convenient way to achieve a bold version of `UIFont.TextStyle.title3`. Designed to be used in conjunction with
    /// `UIFontMetrics(forTextStyle: .title3).scaledFont(for: UIFont.boldTitle3)` for easier Dynamic Type support.
    static var boldTitle3: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
    }

    /// A convenient way to achieve a bold version of `UIFont.TextStyle.body`. Designed to be used in conjunction with
    /// `UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.boldBody)` for easier Dynamic Type support.
    static var boldBody: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
    }

    static var avenirNextBoldLargeTitle: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize) ?? .preferredFont(forTextStyle: .largeTitle)
    }

    static var avenirNextBoldTitle1: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIFont.preferredFont(forTextStyle: .title1).pointSize) ?? .preferredFont(forTextStyle: .title1)
    }

    static var avenirNextBoldTitle3: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIFont.preferredFont(forTextStyle: .title3).pointSize) ?? .preferredFont(forTextStyle: .title3)
    }

    static var avenirNextBoldBody: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIFont.preferredFont(forTextStyle: .body).pointSize) ?? .preferredFont(forTextStyle: .body)
    }

    static var avenirNextRegularBody: UIFont {
        UIFont(name: FontConstants.avenirNextRegular, size: UIFont.preferredFont(forTextStyle: .body).pointSize) ?? .preferredFont(forTextStyle: .body)
    }

    static var avenirNextRegularCaption2: UIFont {
        UIFont(name: FontConstants.avenirNextRegular, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize) ?? .preferredFont(forTextStyle: .caption2)
    }
}
