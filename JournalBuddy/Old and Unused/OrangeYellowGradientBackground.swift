//
//  OrangeYellowGradientBackground.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/11/23.
//

import UIKit

class OrangeYellowGradientBackground: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemOrange.cgColor, UIColor.systemYellow.cgColor]
        gradient.frame = bounds

        layer.addSublayer(gradient)
    }
}
