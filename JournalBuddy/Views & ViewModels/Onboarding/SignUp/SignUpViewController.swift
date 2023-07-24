//
//  SignUpViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

import Combine
import UIKit

class SignUpViewController: UIViewController, MainViewController {
    var coordinator: OnboardingCoordinator?
    var viewModel: SignUpViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: OnboardingCoordinator, viewModel: SignUpViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SignUpView(viewModel: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        subscribeToPublishers()
    }

    func configure() {
        navigationItem.largeTitleDisplayMode = .never
        title = "Sign Up"
    }

    func subscribeToPublishers() {

    }

    func showError(_ error: Error) {

    }
}
