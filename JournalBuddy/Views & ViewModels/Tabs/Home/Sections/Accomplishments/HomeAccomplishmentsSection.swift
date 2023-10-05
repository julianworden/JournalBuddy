//
//  HomeAccomplishmentsSection.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/9/23.
//

import Combine
import UIKit

class HomeAccomplishmentsSection: UIView {
    private lazy var primaryBackgroundBox = HomeSectionPrimaryBox()
    private lazy var titleLabel = UILabel()
    private lazy var primaryBoxContentStack = UIStackView(arrangedSubviews: [accomplishmentsStack, secondaryBox])
    private lazy var accomplishmentsStack = UIStackView()
    private lazy var secondaryBox = HomeSectionSecondaryBox(
        iconName: "trophy",
        text: "\(viewModel.currentUser.numberOfCompleteGoals)\nGoals Achieved"
    )

    var primaryBoxContentStackAxis: NSLayoutConstraint.Axis {
        if UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium {
            return .vertical
        } else {
            return .horizontal
        }
    }

    var primaryBoxContentStackAlignment: UIStackView.Alignment {
        if UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium {
            return .fill
        } else {
            return .center
        }
    }

    let viewModel: HomeViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configure()
        makeAccessible()
        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        titleLabel.text = "Accomplishments 🎉"
        titleLabel.font = UIFontMetrics.avenirNextBoldTitle2
        titleLabel.textColor = .primaryElement
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        primaryBackgroundBox.backgroundColor = .groupedBackground

        primaryBoxContentStack.spacing = 20
        primaryBoxContentStack.alignment = primaryBoxContentStackAlignment
        primaryBoxContentStack.axis = primaryBoxContentStackAxis

        accomplishmentsStack.axis = .vertical
        accomplishmentsStack.spacing = 0
    }

    func makeAccessible() {
        titleLabel.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {
        subscribeToGoalsArrayUpdates()
        subscribeToDynamicTypeChanges()
        subscribeToCompleteGoalCountUpdates()
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

            accomplishmentsStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 170),
            secondaryBox.widthAnchor.constraint(greaterThanOrEqualToConstant: 110)
        ])
    }
    
    func subscribeToGoalsArrayUpdates() {
        viewModel.$userGoals
            .sink { [weak self] goals in
                self?.addGoalsToStackView(goals)
            }
            .store(in: &cancellables)
    }
    
    func subscribeToDynamicTypeChanges() {
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] _ in
                self?.adjustLayoutForNewPreferredContentSizeCategory()
            }
            .store(in: &cancellables)
    }
    
    func subscribeToCompleteGoalCountUpdates() {
        NotificationCenter.default.publisher(for: .goalWasCompleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                let newNumberOfCompleteGoals = self.viewModel.currentUser.numberOfCompleteGoals + 1
                self.viewModel.currentUser.incrementNumberOfCompleteGoals()
                self.secondaryBox.updateText(with: "\(newNumberOfCompleteGoals)\nGoals Achieved")
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .goalWasDeleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let deletedGoal = notification.userInfo?[NotificationConstants.deletedGoal] as? Goal else {
                    print("❌ .goalWasDeleted notification posted without goal data.")
                    return
                }
                                                               
                if deletedGoal.isComplete {
                    let newNumberOfCompleteGoals = self.viewModel.currentUser.numberOfCompleteGoals - 1
                    self.viewModel.currentUser.decrementNumberOfCompleteGoals()
                    self.secondaryBox.updateText(with: "\(newNumberOfCompleteGoals)\nGoals Achieved")
                }
            }
            .store(in: &cancellables)
    }

    func adjustLayoutForNewPreferredContentSizeCategory() {
        primaryBoxContentStack.alignment = primaryBoxContentStackAlignment
        primaryBoxContentStack.axis = primaryBoxContentStackAxis
    }

    func addGoalsToStackView(_ goals: [Goal]) {
        for (index, goal) in goals.enumerated() {
            // Don't show divider at the bottom of last row
            let displayDividerInRow = index != goals.count - 1
            let row = HomeAccomplishmentsStackViewRow(accomplishmentName: goal.name, displayDivider: displayDividerInRow)
            accomplishmentsStack.addArrangedSubview(row)
        }
    }
}
