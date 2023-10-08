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
    private lazy var primaryBoxContentStack = UIStackView(arrangedSubviews: [accomplishmentsStack, noCompleteGoalsFoundView, secondaryBox])
    private lazy var accomplishmentsStack = UIStackView()
    private lazy var noCompleteGoalsFoundView = NoContentFoundView(
        title: "No Completed Goals Found",
        message: "Your most recently completed goals will appear here."
    )
    private lazy var secondaryBox = HomeSectionSecondaryBox(
        iconName: "trophy",
        text: AttributedString(localized: "\(viewModel.currentUser.numberOfCompleteGoals) Goal")
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
        
        noCompleteGoalsFoundView.isHidden = true
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

        #warning("Make constraints for primary box individual contents equal to a percentage of the primary box width. When type is very big, make them the full width.")
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
            noCompleteGoalsFoundView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            secondaryBox.widthAnchor.constraint(greaterThanOrEqualToConstant: 75)
        ])
    }
    
    func subscribeToGoalsArrayUpdates() {
        viewModel.$refreshGoalsList
            .sink { [weak self] refresh in
                guard let self,
                      refresh else { return }
                
                if self.viewModel.threeMostRecentlyCompletedGoals.isEmpty {
                    self.presentNoCompleteGoalsFoundUI()
                } else {
                    self.presentCompleteGoalsFoundUI()
                    self.addGoalsToStackView(self.viewModel.threeMostRecentlyCompletedGoals)
                } 
                
                self.viewModel.refreshGoalsList = false
            }
            .store(in: &cancellables)
    }
    
    func presentNoCompleteGoalsFoundUI() {
        accomplishmentsStack.isHidden = true
        noCompleteGoalsFoundView.isHidden = false
    }
    
    func presentCompleteGoalsFoundUI() {
        accomplishmentsStack.isHidden = false
        noCompleteGoalsFoundView.isHidden = true
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
                self.secondaryBox.updateText(with: AttributedString(localized: "\(newNumberOfCompleteGoals) Goal"))
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
                    self.secondaryBox.updateText(with: AttributedString(localized: "\(newNumberOfCompleteGoals) Goal"))
                }
            }
            .store(in: &cancellables)
    }

    func adjustLayoutForNewPreferredContentSizeCategory() {
        primaryBoxContentStack.alignment = primaryBoxContentStackAlignment
        primaryBoxContentStack.axis = primaryBoxContentStackAxis
    }

    func addGoalsToStackView(_ goals: [Goal]) {
        if !accomplishmentsStack.arrangedSubviews.isEmpty {
            for view in accomplishmentsStack.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
        
        for (index, goal) in goals.enumerated() {
            // Don't show divider at the bottom of last row
            let displayDividerInRow = index != goals.count - 1
            let row = HomeAccomplishmentsStackViewRow(accomplishmentName: goal.name, displayDivider: displayDividerInRow)
            accomplishmentsStack.addArrangedSubview(row)
        }
    }
}
