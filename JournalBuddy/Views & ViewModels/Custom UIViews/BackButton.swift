//
//  BackButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/4/23.
//

import UIKit

class BackButton: UIButton {    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        let normalChevron = UIImage(systemName: "chevron.left", withConfiguration: .boldLargeScale)
        let disabledChevron = UIImage(
            systemName: "chevron.left",
            withConfiguration: .boldLargeScale.applying(.disabledElementColor)
        )
        setImage(normalChevron, for: .normal)
        setImage(disabledChevron, for: .highlighted)
        titleLabel?.font = UIFontMetrics.avenirNextRegularBody
        setTitleColor(.primaryElement, for: .normal)
        setTitleColor(.disabled, for: .highlighted)
    }
}
