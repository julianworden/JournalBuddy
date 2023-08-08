//
//  HomeActivityStreakSection.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/7/23.
//

import Combine
import UIKit

class HomeActivityStreakSection: UIView {
    private lazy var primaryBackgroundBox = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var primaryBoxContentStack = UIStackView(arrangedSubviews: [streakLabel, secondaryBackgroundBox])
    private lazy var streakLabel = UILabel()
    private lazy var secondaryBackgroundBox = UIView()
    private lazy var secondaryBoxContentStack = UIStackView(arrangedSubviews: [streakNumberIcon, streakNumberLabel])
    private lazy var streakNumberIcon = UIImageView(image: UIImage(systemName: "calendar", withConfiguration: .primaryElementColor))
    private lazy var streakNumberLabel = UILabel()

    var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        makeAccessible()
        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        titleLabel.text = "Activity Streak 📝"
        titleLabel.font = UIFontMetrics.avenirNextBoldTitle2
        titleLabel.textColor = .primaryElement
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        primaryBackgroundBox.backgroundColor = .groupedBackground
        primaryBackgroundBox.layer.cornerRadius = 15
        primaryBackgroundBox.layer.shadowOpacity = 0.2
        primaryBackgroundBox.layer.shadowOffset = CGSize(width: 0, height: 2)

        primaryBoxContentStack.spacing = 10

        streakLabel.text = "You're on a streak! Create an entry every day to keep it going."
        streakLabel.font = UIFontMetrics.avenirNextRegularBody
        streakLabel.textColor = .primaryElement
        streakLabel.numberOfLines = 0

        secondaryBackgroundBox.backgroundColor = .background
        secondaryBackgroundBox.layer.cornerRadius = 15
        secondaryBackgroundBox.layer.shadowOpacity = 0.2
        secondaryBackgroundBox.layer.shadowOffset = CGSize(width: 0, height: 2)

        secondaryBoxContentStack.axis = .vertical

        streakNumberIcon.contentMode = .scaleAspectFit

        streakNumberLabel.text = "5 Day Streak"
        streakNumberLabel.textColor = .primaryElement
        streakNumberLabel.textAlignment = .center
        streakNumberLabel.numberOfLines = 0
        streakNumberLabel.font = UIFontMetrics.avenirNextRegularBody
    }

    func makeAccessible() {
        titleLabel.adjustsFontForContentSizeCategory = true
        streakLabel.adjustsFontForContentSizeCategory = true
        streakNumberLabel.adjustsFontForContentSizeCategory = true

        adjustLayoutIfNeeded()
    }

    func adjustLayoutIfNeeded() {
        primaryBoxContentStack.axis = if UIApplication.shared.preferredContentSizeCategory >= .accessibilityLarge {
            .vertical
        } else {
            .horizontal
        }

        streakLabel.textAlignment = if UIApplication.shared.preferredContentSizeCategory >= .accessibilityLarge {
            .center
        } else {
            .left
        }
    }

    func subscribeToPublishers() {
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] _ in
                self?.adjustLayoutIfNeeded()
            }
            .store(in: &cancellables)
    }

    func constrain() {
        addConstrainedSubviews(titleLabel, primaryBackgroundBox)
        primaryBackgroundBox.addConstrainedSubviews(primaryBoxContentStack)
        secondaryBackgroundBox.addConstrainedSubview(secondaryBoxContentStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: primaryBackgroundBox.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: primaryBackgroundBox.trailingAnchor),

            primaryBackgroundBox.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            primaryBackgroundBox.bottomAnchor.constraint(equalTo: bottomAnchor),
            primaryBackgroundBox.leadingAnchor.constraint(equalTo: leadingAnchor),
            primaryBackgroundBox.trailingAnchor.constraint(equalTo: trailingAnchor),

            primaryBoxContentStack.topAnchor.constraint(equalTo: primaryBackgroundBox.topAnchor, constant: 10),
            primaryBoxContentStack.bottomAnchor.constraint(equalTo: primaryBackgroundBox.bottomAnchor, constant: -10),
            primaryBoxContentStack.leadingAnchor.constraint(equalTo: primaryBackgroundBox.leadingAnchor, constant: 10),
            primaryBoxContentStack.trailingAnchor.constraint(equalTo: primaryBackgroundBox.trailingAnchor, constant: -10),

            secondaryBoxContentStack.topAnchor.constraint(equalTo: secondaryBackgroundBox.topAnchor, constant: 5),
            secondaryBoxContentStack.bottomAnchor.constraint(equalTo: secondaryBackgroundBox.bottomAnchor, constant: -5),
            secondaryBoxContentStack.leadingAnchor.constraint(equalTo: secondaryBackgroundBox.leadingAnchor, constant: 10),
            secondaryBoxContentStack.trailingAnchor.constraint(equalTo: secondaryBackgroundBox.trailingAnchor, constant: -10),
            secondaryBoxContentStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),

            streakNumberIcon.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            streakNumberIcon.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
}
