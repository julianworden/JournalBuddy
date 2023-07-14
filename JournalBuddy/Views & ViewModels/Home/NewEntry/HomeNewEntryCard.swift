//
//  HomeNewEntryCard.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/13/23.
//

import UIKit

class HomeNewEntryCard: UIView {
    let type: HomeNewEntryButtonType

    private lazy var cardBackground = HomeViewCardBackground()
    private lazy var imageAndTextStack = UIStackView(arrangedSubviews: [imageView, newEntryLabel])
    private lazy var imageView = UIImageView()
    private lazy var newEntryLabel = UILabel()

    init(type: HomeNewEntryButtonType) {
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

        newEntryLabel.text = type.titleLabel
        newEntryLabel.textColor = .white
        newEntryLabel.textAlignment = .center
        newEntryLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldTitle2)
        newEntryLabel.numberOfLines = 2
    }

    func makeAccessible() {
        newEntryLabel.adjustsFontForContentSizeCategory = true
    }

    func constrain() {
        addConstrainedSubviews(cardBackground, imageAndTextStack)

        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: trailingAnchor),

            imageAndTextStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageAndTextStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            imageView.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
}
