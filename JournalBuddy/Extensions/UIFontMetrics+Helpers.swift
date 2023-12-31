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
    
    static var avenirNextRegularTitle2: UIFont {
        UIFontMetrics(forTextStyle: .title2).scaledFont(for: .avenirNextRegularTitle2)
    }

    static var avenirNextBoldBody: UIFont {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: .avenirNextBoldBody)
    }

    static var avneirNextDemiBoldBody: UIFont {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: .avenirNextDemiBoldBody)
    }

    static var avenirNextRegularBody: UIFont {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: .avenirNextRegularBody)
    }
    
    static var avenirNextBoldCallout: UIFont {
        UIFontMetrics(forTextStyle: .callout).scaledFont(for: .avenirNextBoldCallout)
    }
    
    static var avenirNextRegularCallout: UIFont {
        UIFontMetrics(forTextStyle: .callout).scaledFont(for: .avenirNextRegularCallout)
    }
    
    static var avenirNextBoldFootnote: UIFont {
        UIFontMetrics(forTextStyle: .footnote).scaledFont(for: .avenirNextBoldFootnote)
    }

    static var avenirNextRegularFootnote: UIFont {
        UIFontMetrics(forTextStyle: .footnote).scaledFont(for: .avenirNextRegularFootnote)
    }
}
