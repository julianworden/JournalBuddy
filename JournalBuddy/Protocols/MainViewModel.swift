//
//  MainViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/15/23.
//

import Combine

/// A protocol to which all view models belonging to a `MainView` and/or `MainViewController` must conform.
protocol MainViewModel {
    var error: Error? { get set }
}
