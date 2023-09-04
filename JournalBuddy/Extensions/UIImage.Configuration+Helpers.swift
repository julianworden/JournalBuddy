//
//  UIImage.Configuration+largeScale.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/6/23.
//

import UIKit

extension UIImage.Configuration {
    static var largeScale: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(scale: .large)
    }
    
    static var boldLargeScale: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(weight: .bold).applying(largeScale)
    }

    static var destructive: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(paletteColors: [.background, .destructive])
    }

    static var primaryElementColor: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(paletteColors: [.primaryElement])
    }
    
    static var disabledElementColor: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(paletteColors: [.disabled])
    }
    
    static var createVideoView: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(paletteColors: [.background, .primaryElement])
    }
}
