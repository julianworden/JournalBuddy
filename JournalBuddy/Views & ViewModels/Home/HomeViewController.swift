//
//  HomeViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import Combine
import SwiftPlus
import UIKit

class HomeViewController: UIViewController {
    weak var coordinator: HomeCoordinator?
    let viewModel = HomeViewModel()

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = HomeView(viewModel: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        navigationItem.largeTitleDisplayMode = .always
        title = "Journal Buddy"
    }
}

//#Preview {
//    let navigationController = UINavigationController(rootViewController: HomeViewController())
//    navigationController.navigationBar.prefersLargeTitles = true
//    return navigationController
//}
