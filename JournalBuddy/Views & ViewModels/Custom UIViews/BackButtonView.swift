//
//  BackButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/4/23.
//

import UIKit

#warning("Turn this into a custom UIButton.Configuration instead.")

/// A view that contains a custom back button. This view subclasses `UIView` instead of `UIButton` to avoid
/// creating a custom `UIButton.Configuration`, which is more complicated than subclassing `UIView`.
class BackButtonView: UIView {
    var backButton: UIButton!
    
    init(buttonTarget: UIViewController, buttonSelector: Selector) {
        super.init(frame: .zero)
        
        configure(with: buttonSelector, andTarget: buttonTarget)
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with selector: Selector, andTarget target: UIViewController) {
        var backButtonConfiguration = UIButton.Configuration.plain()
        backButtonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        backButtonConfiguration.attributedTitle = AttributedString("Back", attributes: AttributeContainer([.font: UIFontMetrics.avenirNextRegularBody]))
        backButtonConfiguration.imagePadding = 7
        backButton = UIButton(configuration: backButtonConfiguration)
        let normalChevron = UIImage(systemName: "chevron.left", withConfiguration: .boldLargeScale)
        let disabledChevron = UIImage(systemName: "chevron.left", withConfiguration: .boldLargeScale.applying(.disabledElementColor))
        backButton.setImage(normalChevron, for: .normal)
        backButton.setImage(disabledChevron, for: .highlighted)
        backButton.titleLabel?.font = UIFontMetrics.avenirNextRegularBody
        backButton.setTitleColor(.primaryElement, for: .normal)
        backButton.setTitleColor(.disabled, for: .highlighted)
        backButton.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    func constrain() {
        addConstrainedSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
