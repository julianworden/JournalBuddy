//
//  HomeSectionSecondaryBox.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/9/23.
//

import UIKit

class HomeSectionSecondaryBox: UIView {
    private lazy var contentStack = UIStackView(arrangedSubviews: [iconImageView, textLabel])
    private lazy var iconImage = UIImage(systemName: iconName, withConfiguration: .largeScale)?.withTintColor(.primaryElement)
    private lazy var iconImageView = UIImageView(image: iconImage)
    private lazy var textLabel = UILabel()

    let iconName: String
    let text: AttributedString

    init(iconName: String, text: AttributedString) {
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
        contentStack.spacing = 3

        textLabel.attributedText = NSAttributedString(text)
        textLabel.font = UIFontMetrics.avenirNextRegularBody
        textLabel.textColor = .primaryElement
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2

        iconImageView.contentMode = .scaleAspectFit
    }

    func makeAccessible() {
        textLabel.adjustsFontForContentSizeCategory = true
    }

    func constrain() {
        addConstrainedSubviews(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            iconImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            iconImageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
    
    func updateText(with newText: AttributedString) {
        textLabel.attributedText = NSAttributedString(newText)
    }
}
