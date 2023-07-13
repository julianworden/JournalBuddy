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
    private lazy var stackView = UIStackView(arrangedSubviews: [howAreYouFeelingCard, yourLatestEntriesCard])
    private lazy var howAreYouFeelingCard = HomeHowAreYouFeelingCard()
    private lazy var yourLatestEntriesCard = YourLatestEntriesCard()

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

        stackView.axis = .vertical
        stackView.spacing = 20
    }

    func constrain() {
        scrollView.addConstrainedSubview(stackView)
        view.addConstrainedSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            howAreYouFeelingCard.heightAnchor.constraint(equalToConstant: 90),
            howAreYouFeelingCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            howAreYouFeelingCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            yourLatestEntriesCard.heightAnchor.constraint(equalToConstant: 187),
            yourLatestEntriesCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            yourLatestEntriesCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
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
