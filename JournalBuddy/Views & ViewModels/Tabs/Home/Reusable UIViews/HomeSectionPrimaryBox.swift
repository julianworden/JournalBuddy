//
//  HomeSectionPrimaryBox.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/11/23.
//

import UIKit

class HomeSectionPrimaryBox: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .groupedBackground
        layer.cornerRadius = 15
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}
