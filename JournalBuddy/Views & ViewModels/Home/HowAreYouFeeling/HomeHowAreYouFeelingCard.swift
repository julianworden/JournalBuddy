//
//  HomeHowAreYouFeelingCard.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/11/23.
//

import UIKit

class HomeHowAreYouFeelingCard: UIView {
    private lazy var cardBackground = HomeViewCardBackground()
    private lazy var headerLabel = UILabel()
    private lazy var emojiStack = UIStackView(arrangedSubviews: [greatEmoji, goodEmoji, okayEmoji, badEmoji, terribleEmoji])
    private lazy var greatEmoji = UIButton()
    private lazy var goodEmoji = UIButton()
    private lazy var okayEmoji = UIButton()
    private lazy var badEmoji = UIButton()
    private lazy var terribleEmoji = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

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

        headerLabel.text = "How are you feeling today?"
        headerLabel.numberOfLines = 0
        headerLabel.textAlignment = .center
        headerLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldTitle2)
        headerLabel.textColor = .white

        emojiStack.distribution = .equalCentering
        emojiStack.axis = .horizontal

        greatEmoji.setTitle("😄", for: .normal)
        greatEmoji.titleLabel?.adjustsFontSizeToFitWidth = true
        greatEmoji.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)

        goodEmoji.setTitle("🙂", for: .normal)
        goodEmoji.titleLabel?.adjustsFontSizeToFitWidth = true
        goodEmoji.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)

        okayEmoji.setTitle("😐", for: .normal)
        okayEmoji.titleLabel?.adjustsFontSizeToFitWidth = true
        okayEmoji.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)

        badEmoji.setTitle("😕", for: .normal)
        badEmoji.titleLabel?.adjustsFontSizeToFitWidth = true
        badEmoji.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)

        terribleEmoji.setTitle("😭", for: .normal)
        terribleEmoji.titleLabel?.adjustsFontSizeToFitWidth = true
        terribleEmoji.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
    }

    func makeAccessible() {
        headerLabel.adjustsFontForContentSizeCategory = true
        greatEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        goodEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        okayEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        badEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        terribleEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    func constrain() {
        addConstrainedSubviews(cardBackground, headerLabel, emojiStack)

        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: trailingAnchor),

            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            emojiStack.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            emojiStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emojiStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            emojiStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
