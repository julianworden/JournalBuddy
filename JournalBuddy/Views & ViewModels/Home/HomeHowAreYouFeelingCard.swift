//
//  HomeHowAreYouFeelingCard.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/11/23.
//

import UIKit

class HomeHowAreYouFeelingCard: UIView {
    lazy private var cardBackground = HomeViewCardBackground()
    lazy private var headerLabel = UILabel()
    lazy private var emojiStack = UIStackView(arrangedSubviews: [greatEmoji, goodEmoji, okayEmoji, badEmoji, terribleEmoji])
    lazy private var greatEmoji = UIButton()
    lazy private var goodEmoji = UIButton()
    lazy private var okayEmoji = UIButton()
    lazy private var badEmoji = UIButton()
    lazy private var terribleEmoji = UIButton()

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
        headerLabel.text = "How are you feeling today?"
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
        greatEmoji.maximumContentSizeCategory = .extraExtraExtraLarge

        greatEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        greatEmoji.maximumContentSizeCategory = .extraExtraExtraLarge

        goodEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        goodEmoji.maximumContentSizeCategory = .extraExtraExtraLarge

        okayEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        okayEmoji.maximumContentSizeCategory = .extraExtraExtraLarge

        badEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        badEmoji.maximumContentSizeCategory = .extraExtraExtraLarge

        terribleEmoji.titleLabel?.adjustsFontForContentSizeCategory = true
        terribleEmoji.maximumContentSizeCategory = .extraExtraExtraLarge
    }

    func constrain() {
        addConstrainedSubviews(cardBackground, headerLabel, emojiStack)

        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: trailingAnchor),

            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            emojiStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emojiStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            emojiStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),

            greatEmoji.widthAnchor.constraint(equalToConstant: 44),
            greatEmoji.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
