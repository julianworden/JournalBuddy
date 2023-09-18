//
//  SFSymbolButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/18/23.
//

import UIKit

class SFSymbolButton: UIButton {
    let symbol: UIImage

    init(symbol: UIImage) {
        self.symbol = symbol

        super.init(frame: .zero)

        configure()
        makeAccessible()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        setImage(symbol, for: .normal)
        tintColor = .primaryElement

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
    }
    
    func makeAccessible() {
        adjustsImageSizeForAccessibilityContentSizeCategory = true
    }

    /// Changes the tint color of the button as soon as it's touched.
    @objc func touchDown(_ sender: UIButton) {
        tintColor = .disabled
    }

    /// Changes the tint color of the button as soon as it's released after being touched.
    @objc func touchUpInside(_ sender: UIButton) {
        tintColor = .primaryElement
    }

    /// Changes the tint color of the button as soon as it's released from outside of the bounds
    /// of the button after being touched.
    @objc func touchUpOutside(_ sender: UIButton) {
        tintColor = .primaryElement
    }
}
