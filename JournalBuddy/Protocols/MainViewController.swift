//
//  MainViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/14/23.
//

import Combine

protocol MainViewController {
    associatedtype ViewModel: MainViewModel

    var cancellables: Set<AnyCancellable> { get set }
    var viewModel: ViewModel! { get set }
    
    func configure()
    func constrain()
    func makeAccessible()
    func subscribeToPublishers()
    func showError(_ error: Error)
}
