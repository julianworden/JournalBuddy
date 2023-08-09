//
//  UIFont+boldLargeTitle.swift
//  WatchaGot
//
//  Created by Julian Worden on 7/5/23.
//

import UIKit

extension UIFont {
    static var boldLargeTitle: UIFont {
        boldSystemFont(ofSize: UIConstants.largeTitleSize)
    }

    static var boldTitle2: UIFont {
        boldSystemFont(ofSize: UIConstants.title2Size)
    }

    static var boldBody: UIFont {
        boldSystemFont(ofSize: UIFont.labelFontSize)
    }

    static var regularBody: UIFont {
        systemFont(ofSize: UIFont.labelFontSize)
    }

    static var avenirNextBoldLargeTitle: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIConstants.largeTitleSize) ?? boldLargeTitle
    }

    static var avenirNextBoldTitle2: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIConstants.title2Size) ?? boldTitle2
    }

    static var avenirNextBoldBody: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIFont.labelFontSize) ?? boldBody
    }

    static var avenirNextRegularBody: UIFont {
        UIFont(name: FontConstants.avenirNextRegular, size: UIFont.labelFontSize) ?? regularBody
    }
}
