//
//  EntriesViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class EntriesViewController: UIViewController, MainViewController {
    weak var coordinator: EntriesCoordinator?
    let viewModel = EntriesViewModel()
    var cancellables = Set<AnyCancellable>()

    init(coordinator: EntriesCoordinator) {
        self.coordinator = coordinator

        super.init(nibName: nil, bundle: nil)

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = EntriesView(viewModel: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        navigationItem.title = "Entries"
        navigationItem.largeTitleDisplayMode = .always
    }

    func subscribeToPublishers() {

    }

    func showError(_ error: Error) {
        self.coordinator?.viewController(self, shouldPresentError: error)
    }
}
