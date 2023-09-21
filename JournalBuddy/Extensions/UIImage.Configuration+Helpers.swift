//
//  UIImage.Configuration+largeScale.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/6/23.
//

import UIKit

extension UIImage.Configuration {
    static var largeScale: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(
            scale: .large
        ).applying(UIImage.SymbolConfiguration(textStyle: .body))
    }
    
    static var boldLargeScale: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(
            weight: .semibold
        ).applying(largeScale)
    }

    static var destructiveColorWithBackground: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(
            paletteColors: [
                .background,
                .destructive
            ]
        ).applying(UIImage.SymbolConfiguration(textStyle: .body))
    }
    
    static var destructiveColorWithoutBackground: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(
            paletteColors: [.destructive]
        ).applying(UIImage.SymbolConfiguration(textStyle: .body))
    }
    
    static var destructiveDisabledColorWithBackground: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(
            paletteColors: [
                .background,
                .destructiveDisabled
            ]
        ).applying(UIImage.SymbolConfiguration(textStyle: .body))
    }

    static var primaryElementColor: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(paletteColors: [.primaryElement])
    }
    
    static var backgroundColor: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(paletteColors: [.background]
        ).applying(UIImage.SymbolConfiguration(textStyle: .body))
    }
    
    static var disabledElementColor: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(paletteColors: [.disabled])
    }
    
    #warning("Change the name of this since it's being used for voice entries too")
    static var createVideoViewButton: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(
            paletteColors: [
                .background,
                .primaryElement
            ]
        ).applying(.largeScale)
    }
}
