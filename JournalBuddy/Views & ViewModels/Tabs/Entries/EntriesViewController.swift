//
//  EntriesViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class EntriesViewController: UIViewController, MainViewController {
    private lazy var createEntryButton = UIBarButtonItem(image: UIImage(systemName: "plus"), menu: createEntryMenu)
    private lazy var createEntryMenu = UIMenu(
        children: [createNewTextEntryButton, createNewVideoEntryButton, createNewVoiceEntryButton]
    )
    #warning("Make handler references weak")
    private lazy var createNewTextEntryButton = UIAction(
        title: "New Text Entry",
        image: UIImage(systemName: "square.and.pencil"),
        handler: newTextEntryMenuButtonTapped
    )
    private lazy var createNewVideoEntryButton = UIAction(
        title: "New Video Entry",
        image: UIImage(systemName: "video"),
        handler: newVideoEntryMenuButtonTapped
    )
    private lazy var createNewVoiceEntryButton = UIAction(
        title: "New Voice Entry",
        image: UIImage(systemName: "mic"),
        handler: newVoiceEntryMenuButtonTapped
    )

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
        navigationItem.rightBarButtonItem = createEntryButton
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

    func newTextEntryMenuButtonTapped(_ action: UIAction) {
        self.coordinator?.presentAddEditTextEntryViewController(withTextEntryToEdit: nil)
    }

    func newVideoEntryMenuButtonTapped(_ action: UIAction) {

    }

    func newVoiceEntryMenuButtonTapped(_ action: UIAction) {

    }
}

extension EntriesViewController: EntriesViewDelegate {
    func entriesViewDidSelectTextEntry(_ textEntry: TextEntry) {
        coordinator?.presentAddEditTextEntryViewController(withTextEntryToEdit: textEntry)
    }
}
