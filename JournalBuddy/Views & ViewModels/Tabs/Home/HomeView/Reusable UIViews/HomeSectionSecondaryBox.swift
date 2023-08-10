//
//  HomeSectionSecondaryBox.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/9/23.
//

import UIKit

class HomeSectionSecondaryBox: UIView {
    private lazy var contentStack = UIStackView(arrangedSubviews: [iconImageView, textLabel])
    private lazy var iconImageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: .primaryElementColor))
    private lazy var textLabel = UILabel()

    let iconName: String
    let text: String

    init(iconName: String, text: String) {
        self.iconName = iconName
        self.text = text

        super.init(frame: .zero)

        configure()
        makeAccessible()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .secondaryGroupedBackground
        layer.cornerRadius = 15
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)

        contentStack.axis = .vertical

        textLabel.text = text
        textLabel.font = UIFontMetrics.avenirNextRegularBody
        textLabel.textColor = .primaryElement
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0

        iconImageView.contentMode = .scaleAspectFit
    }

    func makeAccessible() {
        textLabel.adjustsFontForContentSizeCategory = true
    }

    func constrain() {
        addConstrainedSubviews(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),

            iconImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            iconImageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
}
