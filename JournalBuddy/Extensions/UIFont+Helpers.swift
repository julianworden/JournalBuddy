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
    
    static var boldFootnote: UIFont {
        boldSystemFont(ofSize: UIConstants.footnoteSize)
    }

    static var regularFootnote: UIFont {
        systemFont(ofSize: UIConstants.footnoteSize)
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

    static var avenirNextDemiBoldBody: UIFont {
        UIFont(name: FontConstants.avenirNextDemiBold, size: UIFont.labelFontSize) ?? boldBody
    }

    static var avenirNextRegularBody: UIFont {
        UIFont(name: FontConstants.avenirNextRegular, size: UIFont.labelFontSize) ?? regularBody
    }
    
    static var avenirNextBoldFootnote: UIFont {
        UIFont(name: FontConstants.avenirNextBold, size: UIConstants.footnoteSize) ?? boldFootnote
    }

    static var avenirNextRegularFootnote: UIFont {
        UIFont(name: FontConstants.avenirNextRegular, size: UIConstants.footnoteSize) ?? regularFootnote
    }
}
