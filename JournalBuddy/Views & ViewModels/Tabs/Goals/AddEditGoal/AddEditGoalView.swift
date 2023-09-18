//
//  AddEditGoalView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Combine
import UIKit

final class AddEditGoalView: UIView, MainView {
    private lazy var contentStack = UIStackView(
        arrangedSubviews: [
            goalNameTextField,
            saveGoalButton
        ]
    )
    private lazy var goalNameTextField = MainTextField(type: .name)
    private lazy var saveGoalButton = PrimaryButton(title: "Save")
    
    let viewModel: AddEditGoalViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AddEditGoalViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        configure()
        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .background
        
        contentStack.axis = .vertical
        contentStack.spacing = UIConstants.mainStackViewSpacing
        
        goalNameTextField.delegate = self
        if let goalToEdit = viewModel.goalToEdit {
            goalNameTextField.text = goalToEdit.name
        }
        
        saveGoalButton.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )
    }
    
    func makeAccessible() {
        
    }
    
    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .goalIsSaving:
                    self?.saveGoalButton.isEnabled = false
                    self?.goalNameTextField.isEnabled = false
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func constrain() {
        addConstrainedSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            goalNameTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight),
            
            saveGoalButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.mainStackViewMinimumFormElementHeight)
        ])
    }
    
    @objc func saveButtonTapped() {
        Task {
            await viewModel.saveButtonTapped()
        }
    }
}

extension AddEditGoalView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldTextAfterUpdate = textField.getTextFieldTextAfterUpdate(newStringRange: range, newString: string)

        switch textField.tag {
        case MainTextFieldType.name.tag:
            viewModel.goalName = textFieldTextAfterUpdate
        default:
            print(ErrorMessageConstants.unexpectedTextFieldTagFound(tag: tag))
        }

        return true
    }
}
