//
//  CustomDivider.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/10/23.
//

import UIKit

class CustomDivider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .divider
    }
}
