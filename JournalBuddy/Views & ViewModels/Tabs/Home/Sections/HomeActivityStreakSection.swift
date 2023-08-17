//
//  HomeActivityStreakSection.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/7/23.
//

import Combine
import UIKit

class HomeActivityStreakSection: UIView {
    private lazy var primaryBackgroundBox = HomeSectionPrimaryBox()
    private lazy var titleLabel = UILabel()
    private lazy var primaryBoxContentStack = UIStackView(arrangedSubviews: [streakLabel, secondaryBox])
    private lazy var streakLabel = UILabel()
    private lazy var secondaryBox = HomeSectionSecondaryBox(iconName: "calendar", text: "5 Day Streak")

    let viewModel: HomeViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configure()
        adjustLayoutForDynamicType()
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

        primaryBoxContentStack.spacing = 5

        streakLabel.text = "You're on a streak! Create a new text, video, or voice entry every day to keep it going."
        streakLabel.font = UIFontMetrics.avenirNextRegularBody
        streakLabel.textColor = .primaryElement
        streakLabel.numberOfLines = 0
    }

    func makeAccessible() {
        titleLabel.adjustsFontForContentSizeCategory = true
        streakLabel.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] _ in
                self?.adjustLayoutForDynamicType()
            }
            .store(in: &cancellables)
    }

    func constrain() {
        addConstrainedSubviews(titleLabel, primaryBackgroundBox)
        primaryBackgroundBox.addConstrainedSubviews(primaryBoxContentStack)

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

            secondaryBox.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }

    func adjustLayoutForDynamicType() {
        primaryBoxContentStack.axis = if UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium {
            .vertical
        } else {
            .horizontal
        }

        primaryBoxContentStack.alignment = if UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium {
            .fill
        } else {
            .center
        }

        streakLabel.textAlignment = if UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium {
            .center
        } else {
            .left
        }
    }
}
