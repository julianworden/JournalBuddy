//
//  AddEditGoalViewController.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Combine
import UIKit

class AddEditGoalViewController: UIViewController, MainViewController {
    private lazy var cancelButton = UIBarButtonItem(
        title: "Cancel",
        style: .plain,
        target: self,
        action: #selector(cancelButtonTapped)
    )
    
    weak var coordinator: GoalsCoordinator?
    let viewModel: AddEditGoalViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AddEditGoalViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = AddEditGoalView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure() {
        navigationItem.title = viewModel.navigationTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func subscribeToPublishers() {
        
    }
    
    func showError(_ errorMessage: String) {
        
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
}
