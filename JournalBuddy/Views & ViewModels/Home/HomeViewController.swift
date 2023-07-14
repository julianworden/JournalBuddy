//
//  HomeViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import Combine
import SwiftPlus
import UIKit

class HomeViewController: UIViewController, MainViewController {
    private lazy var scrollView = UIScrollView()
    private lazy var mainVerticalStackView = UIStackView(
        arrangedSubviews: [
            howAreYouFeelingCard,
            yourLatestEntriesCard,
            newVideoAndTextEntryStack
        ]
    )
    private lazy var howAreYouFeelingCard = HomeHowAreYouFeelingCard()
    private lazy var yourLatestEntriesCard = HomeYourLatestEntriesCard()
    private lazy var newVideoAndTextEntryStack = UIStackView(arrangedSubviews: [newTextEntryButton, newVideoEntryButton])
    private lazy var newVideoEntryButton = HomeNewEntryButton(homeNewEntryButtonType: .video)
    private lazy var newTextEntryButton = HomeNewEntryButton(homeNewEntryButtonType: .text)

    let viewModel: HomeViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        constrain()
    }

    func configure() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        title = "Journal Buddy"

        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.spacing = 20
        mainVerticalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        mainVerticalStackView.isLayoutMarginsRelativeArrangement = true

        newVideoAndTextEntryStack.axis = .horizontal
        newVideoAndTextEntryStack.distribution = .fillEqually
        newVideoAndTextEntryStack.spacing = 20

        newTextEntryButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        newVideoEntryButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        newVideoEntryButton.isUserInteractionEnabled = true
    }

    @objc func buttonTapped() {
        print("Button Tapped")
    }

    func constrain() {
        scrollView.addConstrainedSubview(mainVerticalStackView)
        view.addConstrainedSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            mainVerticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainVerticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            howAreYouFeelingCard.heightAnchor.constraint(equalToConstant: 90),
            yourLatestEntriesCard.heightAnchor.constraint(equalToConstant: 187),
            newVideoAndTextEntryStack.heightAnchor.constraint(equalToConstant: 158),
        ])
    }

    func makeAccessible() {

    }

    func subscribeToPublishers() {

    }

    func showError(_ error: Error) {

    }
}

#Preview {
    let navigationController = UINavigationController(rootViewController: HomeViewController(viewModel: HomeViewModel()))
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
