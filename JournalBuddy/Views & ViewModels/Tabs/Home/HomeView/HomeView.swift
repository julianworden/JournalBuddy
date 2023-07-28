//
//  HomeView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import Combine
import UIKit

class HomeView: UIView, MainView {
    private lazy var mainScrollView = UIScrollView()
    private lazy var mainScrollViewContentStack = UIStackView(
        arrangedSubviews: [
            howAreYouFeelingCard,
            yourLatestEntriesCard,
            newVideoAndTextEntryStack,
            newVoiceEntryCalendarStack
        ]
    )
    private lazy var howAreYouFeelingCard = HomeHowAreYouFeelingCard()
    private lazy var yourLatestEntriesCard = HomeYourLatestEntriesCard()
    private lazy var newVideoAndTextEntryStack = UIStackView(arrangedSubviews: [newTextEntryButton, newVideoEntryButton])
    private lazy var newVideoEntryButton = HomeSquareButton(homeSquareButtonType: .video)
    private lazy var newTextEntryButton = HomeSquareButton(homeSquareButtonType: .text)
    private lazy var newVoiceEntryCalendarStack = UIStackView(arrangedSubviews: [newVoiceEntryButton, calendarButton])
    private lazy var newVoiceEntryButton = HomeSquareButton(homeSquareButtonType: .voice)
    private lazy var calendarButton = HomeSquareButton(homeSquareButtonType: .calendar)

    let viewModel: HomeViewModel
    weak var delegate: HomeViewDelegate?
    var cancellables = Set<AnyCancellable>()

    init(viewModel: HomeViewModel, delegate: HomeViewDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate

        super.init(frame: .zero)

        configureDefaultViewState()
        makeAccessible()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDefaultViewState() {
        backgroundColor = .systemBackground

        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.spacing = UIConstants.mainStackViewSpacing
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true

        newVideoAndTextEntryStack.axis = .horizontal
        newVideoAndTextEntryStack.distribution = .fillEqually
        newVideoAndTextEntryStack.spacing = UIConstants.mainStackViewSpacing

        newVoiceEntryCalendarStack.axis = .horizontal
        newVoiceEntryCalendarStack.distribution = .fillEqually
        newVoiceEntryCalendarStack.spacing = UIConstants.mainStackViewSpacing

        newTextEntryButton.addTarget(self, action: #selector(newTextEntryButtonTapped), for: .touchUpInside)
        newVideoEntryButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        newVoiceEntryButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {

    }

    func constrain() {
        mainScrollView.addConstrainedSubview(mainScrollViewContentStack)
        addConstrainedSubview(mainScrollView)

        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            mainScrollViewContentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainScrollViewContentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainScrollViewContentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainScrollViewContentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            mainScrollViewContentStack.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),

            howAreYouFeelingCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            yourLatestEntriesCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 187),
            newVideoAndTextEntryStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 158),
            newVoiceEntryCalendarStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 158)
        ])
    }

    @objc func newTextEntryButtonTapped() {
        delegate?.homeViewDidSelectNewTextEntry()
    }

    @objc func buttonTapped() {
        print("Button Tapped")
    }
}
