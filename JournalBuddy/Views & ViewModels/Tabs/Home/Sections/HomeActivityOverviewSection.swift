//
//  HomeActivityOverviewSection.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/16/23.
//

import Combine
import UIKit

class HomeActivityOverviewSection: UIView {
    private lazy var primaryBackgroundBox = HomeSectionPrimaryBox()
    private lazy var titleLabel = UILabel()
    private lazy var primaryBoxContentStack = UIStackView(
        arrangedSubviews:
            [
                totalTextEntriesBox,
                totalVideoEntriesBox,
                totalVoiceEntriesBox
            ]
    )
    private lazy var totalTextEntriesBox = HomeSectionSecondaryBox(
        iconName: "square.and.pencil",
        text: AttributedString(localized: "\(viewModel.currentUser.numberOfTextEntries) Entry")
    )
    private lazy var totalVideoEntriesBox = HomeSectionSecondaryBox(
        iconName: "video",
        text: AttributedString(localized: "\(viewModel.currentUser.numberOfVideoEntries) Entry")
    )
    private lazy var totalVoiceEntriesBox = HomeSectionSecondaryBox(
        iconName: "mic",
        text: AttributedString(localized: "\(viewModel.currentUser.numberOfVoiceEntries) Entry")
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
        titleLabel.text = "Activity Overview 👀"
        titleLabel.font = UIFontMetrics.avenirNextBoldTitle2
        titleLabel.textColor = .primaryElement
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        primaryBoxContentStack.spacing = 15
        primaryBoxContentStack.distribution = .fillEqually
        primaryBoxContentStack.alignment = primaryBoxContentStackAlignment
        primaryBoxContentStack.axis = primaryBoxContentStackAxis
    }

    func makeAccessible() {
        titleLabel.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {
        subscribeToDynamicTypeSizeChanges()
        subscribeToTextEntryCountChanges()
        subscribeToVideoEntryCountChanges()
        subscribeToVoiceEntryCountChanges()
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

            totalTextEntriesBox.widthAnchor.constraint(greaterThanOrEqualToConstant: 75)
        ])
    }
    
    func subscribeToDynamicTypeSizeChanges() {
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] _ in
                self?.adjustLayoutForNewPreferredContentSizeCategory()
            }
            .store(in: &cancellables)
    }
    
    func subscribeToTextEntryCountChanges() {
        NotificationCenter.default.publisher(for: .textEntryWasCreated)
            .sink { [weak self] _ in
                guard let self else { return }
                
                let newNumberOfTextEntries = self.viewModel.currentUser.numberOfTextEntries + 1
                self.viewModel.currentUser.incrementNumberOfTextEntries()
                self.totalTextEntriesBox.updateText(with: AttributedString(localized: "\(newNumberOfTextEntries) Entry"))
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .textEntryWasDeleted)
            .sink { [weak self] _ in
                guard let self else { return }
                
                let newNumberOfTextEntries = self.viewModel.currentUser.numberOfTextEntries - 1
                self.viewModel.currentUser.decrementNumberOfTextEntries()
                self.totalTextEntriesBox.updateText(with: AttributedString(localized: "\(newNumberOfTextEntries) Entry"))
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVideoEntryCountChanges() {
        NotificationCenter.default.publisher(for: .videoEntryWasCreated)
            .sink { [weak self] _ in
                guard let self else { return }
                
                let newNumberOfVideoEntries = self.viewModel.currentUser.numberOfVideoEntries + 1
                self.viewModel.currentUser.incrementNumberOfVideoEntries()
                self.totalVideoEntriesBox.updateText(with: AttributedString(localized: "\(newNumberOfVideoEntries) Entry"))
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .videoEntryWasDeleted)
            .sink { [weak self] _ in
                guard let self else { return }
                
                let newNumberOfVideoEntries = self.viewModel.currentUser.numberOfVideoEntries - 1
                self.viewModel.currentUser.decrementNumberOfVideoEntries()
                self.totalVideoEntriesBox.updateText(with: AttributedString(localized: "\(newNumberOfVideoEntries) Entry"))
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVoiceEntryCountChanges() {
        NotificationCenter.default.publisher(for: .voiceEntryWasCreated)
            .sink { [weak self] _ in
                guard let self else { return }
                
                let newNumberOfVoiceEntries = self.viewModel.currentUser.numberOfVoiceEntries + 1
                self.viewModel.currentUser.incrementNumberOfVoiceEntries()
                self.totalVoiceEntriesBox.updateText(with: AttributedString(localized: "\(newNumberOfVoiceEntries) Entry"))
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .voiceEntryWasDeleted)
            .sink { [weak self] _ in
                guard let self else { return }
                
                let newNumberOfVoiceEntries = self.viewModel.currentUser.numberOfVoiceEntries - 1
                self.viewModel.currentUser.decrementNumberOfVoiceEntries()
                self.totalVoiceEntriesBox.updateText(with: AttributedString(localized: "\(newNumberOfVoiceEntries) Entry"))
            }
            .store(in: &cancellables)
    }

    func adjustLayoutForNewPreferredContentSizeCategory() {
        primaryBoxContentStack.alignment = primaryBoxContentStackAlignment
        primaryBoxContentStack.axis = primaryBoxContentStackAxis
    }
}
