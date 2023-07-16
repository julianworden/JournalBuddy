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
    let viewModel = HomeViewModel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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

#Preview {
    let navigationController = UINavigationController(rootViewController: HomeViewController())
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
