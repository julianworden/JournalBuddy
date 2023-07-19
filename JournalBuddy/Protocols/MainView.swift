//
//  MainView.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/14/23.
//

import Combine

/// A protocol to which all view's assigned to a `UIViewController`'s `view` property using the `loadView()` method conform.
protocol MainView {
    associatedtype ViewModel: MainViewModel

    var viewModel: ViewModel { get }
    var cancellables: Set<AnyCancellable> { get set }
    
    func configure()
    func constrain()
    func makeAccessible()
    func subscribeToPublishers()
}
