//
//  MainViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/19/23.
//

import Combine

/// A protocol to which all `UIViewController`'s in the app's navigation stack must conform.
protocol MainViewController {
    associatedtype MainViewModelProtocol: MainViewModel
    associatedtype CoordinatorProtocol: Coordinator

    var coordinator: CoordinatorProtocol? { get }
    var viewModel: MainViewModelProtocol { get }
    var cancellables: Set<AnyCancellable> { get set }

    func configure()
    func subscribeToPublishers()
    #warning("Don't have showError in this protocol, use it in Coordinators instead so we're only presenting alerts from Coordinators.")
    func showError(_ errorMessage: String)
}
