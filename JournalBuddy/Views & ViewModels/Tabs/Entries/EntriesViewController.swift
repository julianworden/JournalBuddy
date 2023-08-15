//
//  EntriesViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import SwiftUI
import UIKit

class EntriesViewController: UIViewController, MainViewController {
    private lazy var customMenu = CustomMenu(rows: [
        CustomMenuRow(title: "New Text Entry", iconName: "square.and.pencil", displayDivider: true, target: self, action: #selector(newTextEntryMenuButtonTapped)),
        CustomMenuRow(title: "New Video Entry", iconName: "video", displayDivider: true, target: self, action: #selector(newVideoEntryMenuButtonTapped)),
        CustomMenuRow(title: "New Voice Entry", iconName: "mic", displayDivider: false, target: self, action: #selector(newVoiceEntryMenuButtonTapped))
    ])
    private lazy var dismissCustomMenuGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissCustomMenu))
    private lazy var createEntryButton = UIBarButtonItem(
        title: "Create Entry",
        image: UIImage(systemName: "plus.circle.fill"),
        target: self,
        action: #selector(createEntryButtonTapped)
    )

    weak var coordinator: EntriesCoordinator?
    let viewModel: EntriesViewModel
    var cancellables = Set<AnyCancellable>()

    init(coordinator: EntriesCoordinator, viewModel: EntriesViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
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
        subscribeToPublishers()
        constrain()
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

    // Constraining here instead of in the view because the menu is triggered by a button created in this view controller
    func constrain() {
        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let tabBarControllerView = currentUIWindow.rootViewController?.view else { return }

        tabBarControllerView.addConstrainedSubview(customMenu)

        NSLayoutConstraint.activate([
            customMenu.topAnchor.constraint(equalTo: tabBarControllerView.topAnchor, constant: 100),
            customMenu.leadingAnchor.constraint(greaterThanOrEqualTo: tabBarControllerView.leadingAnchor, constant: 15),
            customMenu.trailingAnchor.constraint(equalTo: tabBarControllerView.trailingAnchor, constant: -15)
        ])
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

    @objc func createEntryButtonTapped() {
        // Prevent visual bug that occurs if the user taps the menu button twice very quickly
        guard !customMenu.isAnimating else { return }

        if !viewModel.customMenuIsShowing {
            customMenu.show { [weak self] in
                self?.addCustomMenuDismissGestureRecognizer()
                self?.viewModel.customMenuIsShowing = true
            }
        } else {
            dismissCustomMenu()
        }
    }

    @objc func newTextEntryMenuButtonTapped() {
        dismissCustomMenu()
        coordinator?.presentAddEditTextEntryViewController(withTextEntryToEdit: nil)
    }

    @objc func newVideoEntryMenuButtonTapped() {

    }

    @objc func newVoiceEntryMenuButtonTapped() {

    }

    @objc func dismissCustomMenu() {
        customMenu.dismiss { [weak self] in
            self?.viewModel.customMenuIsShowing = false
        }
    }

    func addCustomMenuDismissGestureRecognizer() {
        view.addGestureRecognizer(dismissCustomMenuGestureRecognizer)
        coordinator?.navigationController.navigationBar.addGestureRecognizer(dismissCustomMenuGestureRecognizer)

        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let tabBarControllerView = currentUIWindow.rootViewController?.view else { return }

        tabBarControllerView.addGestureRecognizer(dismissCustomMenuGestureRecognizer)
    }

    func removeCustomMenuDismissGestureRecognizer() {
        view.removeGestureRecognizer(dismissCustomMenuGestureRecognizer)
        coordinator?.navigationController.navigationBar.removeGestureRecognizer(dismissCustomMenuGestureRecognizer)

        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let tabBarControllerView = currentUIWindow.rootViewController?.view else { return }

        tabBarControllerView.removeGestureRecognizer(dismissCustomMenuGestureRecognizer)
    }
}

extension EntriesViewController: EntriesViewDelegate {
    func entriesViewDidSelectTextEntry(_ textEntry: TextEntry) {
        coordinator?.presentAddEditTextEntryViewController(withTextEntryToEdit: textEntry)
    }
}
