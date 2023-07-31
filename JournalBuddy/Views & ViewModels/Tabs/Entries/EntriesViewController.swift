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
    let viewModel: EntriesViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: EntriesCoordinator, viewModel: EntriesViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = EntriesView(viewModel: viewModel, delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        Task {
            await viewModel.fetchTextEntries()
        }
    }

    func configure() {
        navigationItem.title = "Entries"
        navigationItem.largeTitleDisplayMode = .always
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .error(let errorMessage):
                    self?.showError(errorMessage)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ errorMessage: String) {
        self.coordinator?.viewController(self, shouldPresentErrorMessage: errorMessage)
    }
}

extension EntriesViewController: EntriesViewDelegate {
    func entriesViewDidSelectTextEntry(_ textEntry: TextEntry) {
        coordinator?.entriesViewDidSelectTextEntry(textEntry)
    }
}
