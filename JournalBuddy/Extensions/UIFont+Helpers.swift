//
//  UIFont+boldLargeTitle.swift
//  WatchaGot
//
//  Created by Julian Worden on 7/5/23.
//

import UIKit

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
}
