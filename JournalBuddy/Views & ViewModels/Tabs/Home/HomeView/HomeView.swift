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
            activityStreakSection
        ]
    )
    private lazy var activityStreakSection = HomeActivityStreakSection(viewModel: viewModel)

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
        backgroundColor = .background

        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.spacing = UIConstants.mainStackViewSpacing
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true
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

            activityStreakSection.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
        ])
    }

    @objc func newTextEntryButtonTapped() {
        delegate?.homeViewDidSelectNewTextEntry()
    }

    @objc func buttonTapped() {
        print("Button Tapped")
    }
}
