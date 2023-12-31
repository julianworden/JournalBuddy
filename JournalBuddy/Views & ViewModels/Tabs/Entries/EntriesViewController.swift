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
    private lazy var createNewEntryMenu = CustomMenu(
        rows: [
            CustomMenuRow(
                title: "New Text Entry",
                iconName: "square.and.pencil",
                displayDivider: true,
                target: self,
                action: #selector(newTextEntryMenuButtonTapped)
            ),
            CustomMenuRow(
                title: "New Video Entry",
                iconName: "video",
                displayDivider: true,
                target: self,
                action: #selector(newVideoEntryMenuButtonTapped)
            ),
            CustomMenuRow(
                title: "New Voice Entry",
                iconName: "mic",
                displayDivider: false,
                target: self,
                action: #selector(newVoiceEntryMenuButtonTapped)
            )
        ]
    )
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
        viewModel.subscribeToPublishers()
        constrain()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)

        if !viewModel.entryQueryHasBeenPerformed {
            Task {
                switch viewModel.selectedEntryType {
                case .text:
                    await viewModel.fetchFirstTextEntryBatch()
                case .video:
                    await viewModel.fetchFirstVideoEntryBatch()
                case .voice:
                    await viewModel.fetchFirstVoiceEntryBatch()
                }
            }
        }
        
        guard let view = view as? EntriesView else {
            print("❌ Incorrect view set as EntriesViewController's view.")
            return
        }
        
        view.updateTextEntryTableViewIfNeeded()
    }

    func configure() {
        navigationItem.title = "Entries"
        navigationItem.largeTitleDisplayMode = .always
        hidesBottomBarWhenPushed = false
    }

    // Constraining here instead of in the view because the menu is triggered by a button created in this view controller
    func constrain() {
        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let tabBarControllerView = currentUIWindow.rootViewController?.view else { return }

        tabBarControllerView.addConstrainedSubview(createNewEntryMenu)

        NSLayoutConstraint.activate([
            createNewEntryMenu.topAnchor.constraint(equalTo: tabBarControllerView.topAnchor, constant: 100),
            createNewEntryMenu.leadingAnchor.constraint(greaterThanOrEqualTo: tabBarControllerView.leadingAnchor, constant: 15),
            createNewEntryMenu.trailingAnchor.constraint(equalTo: tabBarControllerView.trailingAnchor, constant: -15)
        ])
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .fetchedTextEntries, .noTextEntriesFound:
                    self?.navigationItem.rightBarButtonItem = self?.createEntryButton
                case .error(let errorMessage):
                    self?.showError(errorMessage)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ errorMessage: String) {
        self.coordinator?.presentErrorMessage(errorMessage: errorMessage)
    }
    
    /// Adds a `dismissCustomMenuGestureRecognizer` to all elements in the view so that `createNewEntryMenu` is dismissable by tapping anywhere
    /// on the screen. Called when
    func addCustomMenuDismissGestureRecognizer() {
        view.addGestureRecognizer(dismissCustomMenuGestureRecognizer)
        coordinator?.navigationController.navigationBar.addGestureRecognizer(dismissCustomMenuGestureRecognizer)

        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let tabBarControllerView = currentUIWindow.rootViewController?.view else { return }

        tabBarControllerView.addGestureRecognizer(dismissCustomMenuGestureRecognizer)
    }

    /// Removes `dismissCustomMenuGestureRecognizer` from all elements in the view so that it doesn't block the user
    /// from being able to interact with UI elements. Called when `createNewEntryMenu` is dismissed.
    /// on the screen when it's visible.
    func removeCustomMenuDismissGestureRecognizer() {
        view.removeGestureRecognizer(dismissCustomMenuGestureRecognizer)
        coordinator?.navigationController.navigationBar.removeGestureRecognizer(dismissCustomMenuGestureRecognizer)

        guard let currentUIWindow = UIApplication.shared.currentUIWindow(),
              let tabBarControllerView = currentUIWindow.rootViewController?.view else { return }

        tabBarControllerView.removeGestureRecognizer(dismissCustomMenuGestureRecognizer)
    }

    @objc func createEntryButtonTapped() {
        // Prevent visual bug that occurs if the user taps the menu button twice very quickly
        guard !createNewEntryMenu.isAnimating else { return }
        
        addCustomMenuDismissGestureRecognizer()

        if !viewModel.customMenuIsShowing {
            viewModel.customMenuIsShowing = true
            createNewEntryMenu.present { }
        } else {
            dismissCustomMenu()
        }
    }

    @objc func newTextEntryMenuButtonTapped() {
        dismissCustomMenu()
        coordinator?.presentAddEditTextEntryViewController(withTextEntryToEdit: nil)
    }

    @objc func newVideoEntryMenuButtonTapped() {
        dismissCustomMenu()
        coordinator?.presentCreateVideoEntryViewController()
    }

    @objc func newVoiceEntryMenuButtonTapped() {
        dismissCustomMenu()
        coordinator?.presentCreateVoiceEntryViewController()
    }

    @objc func dismissCustomMenu() {
        removeCustomMenuDismissGestureRecognizer()
        
        viewModel.customMenuIsShowing = false

        createNewEntryMenu.dismiss { }
    }
}

extension EntriesViewController: EntriesViewDelegate {
    func entriesViewDidSelectTextEntry(_ entry: TextEntry) {
        guard !createNewEntryMenu.isAnimating,
              !viewModel.customMenuIsShowing else { return }
        
        coordinator?.presentAddEditTextEntryViewController(withTextEntryToEdit: entry)
    }
    
    func entriesViewDidSelectVideoEntry(_ entry: VideoEntry) {
        guard !createNewEntryMenu.isAnimating,
              !viewModel.customMenuIsShowing else { return }
        
        coordinator?.presentWatchVideoEntryViewController(withVideoEntry: entry)
    }
    
    func entriesViewDidSelectVoiceEntry(_ entry: VoiceEntry) {
        guard !createNewEntryMenu.isAnimating,
              !viewModel.customMenuIsShowing else { return }
        
        coordinator?.presentListenToVoiceEntryViewController(for: entry)
    }
}
