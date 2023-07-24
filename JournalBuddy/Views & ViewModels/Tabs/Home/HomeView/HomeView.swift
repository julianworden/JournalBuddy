//
//  HomeView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import Combine
import UIKit

class HomeView: UIView, MainView {
    let viewModel: HomeViewModel
    weak var delegate: HomeViewDelegate?
    var cancellables = Set<AnyCancellable>()

    private lazy var scrollView = UIScrollView()
    private lazy var mainVerticalStackView = UIStackView(
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

        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.spacing = 20
        mainVerticalStackView.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainVerticalStackView.isLayoutMarginsRelativeArrangement = true

        newVideoAndTextEntryStack.axis = .horizontal
        newVideoAndTextEntryStack.distribution = .fillEqually
        newVideoAndTextEntryStack.spacing = 20

        newVoiceEntryCalendarStack.axis = .horizontal
        newVoiceEntryCalendarStack.distribution = .fillEqually
        newVoiceEntryCalendarStack.spacing = 20

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
        scrollView.addConstrainedSubview(mainVerticalStackView)
        addConstrainedSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            mainVerticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainVerticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

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
