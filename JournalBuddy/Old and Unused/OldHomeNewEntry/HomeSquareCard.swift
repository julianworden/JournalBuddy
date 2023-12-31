//
//  HomeSquareCard.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/13/23.
//

import UIKit

class HomeSquareCard: UIView {
    private lazy var cardBackground = OrangeYellowGradientBackground()
    private lazy var imageAndTextStack = UIStackView(arrangedSubviews: [imageView, newEntryLabel])
    private lazy var imageView = UIImageView()
    private lazy var newEntryLabel = UILabel()

    let type: HomeSquareButtonType

    init(type: HomeSquareButtonType) {
        self.type = type

        super.init(frame: .zero)

        configure()
        makeAccessible()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        layer.cornerRadius = 15
        clipsToBounds = true

        imageAndTextStack.axis = .vertical
        imageAndTextStack.spacing = 0

        let image = UIImage(systemName: type.iconName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(751), for: .vertical)

        newEntryLabel.text = type.titleLabel
        newEntryLabel.textColor = .white
        newEntryLabel.textAlignment = .center
        newEntryLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldTitle2)
        newEntryLabel.numberOfLines = 0
    }

    func makeAccessible() {
        newEntryLabel.adjustsFontForContentSizeCategory = true
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }

    func constrain() {
        addConstrainedSubviews(cardBackground, imageAndTextStack)

        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: trailingAnchor),

            imageAndTextStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            imageAndTextStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            imageAndTextStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageAndTextStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 55)
        ])
    }
}
