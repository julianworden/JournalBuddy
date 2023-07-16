//
//  MainViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/14/23.
//

import Combine

protocol MainView {
    associatedtype ViewModel: MainViewModel

    var viewModel: ViewModel { get }
    
    func configure()
    func constrain()
    func makeAccessible()
    func subscribeToPublishers()
    func showError(_ error: Error)
}
