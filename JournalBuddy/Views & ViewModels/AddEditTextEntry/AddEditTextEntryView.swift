//
//  AddEditTextEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class AddEditTextEntryView: UIView, MainView {
    private lazy var entryTextView = UITextView()

    let viewModel: AddEditTextEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: AddEditTextEntryViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDefaultViewState() {
        backgroundColor = .systemBackground

        entryTextView.delegate = self
        entryTextView.text = viewModel.entryTextViewDefaultText
        entryTextView.font = .preferredFont(forTextStyle: .body)
        entryTextView.textColor = viewModel.entryTextViewDefaultTextColor
        entryTextView.showsVerticalScrollIndicator = false
        entryTextView.keyboardDismissMode = .interactive
    }

    func disableTextView() {
        entryTextView.isEditable = false
    }

    func enableTextView() {
        entryTextView.isEditable = true
    }

    func constrain() {
        addConstrainedSubview(entryTextView)

        NSLayoutConstraint.activate([
            entryTextView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            entryTextView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
            entryTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.mainViewLeadingPadding),
            entryTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: UIConstants.mainViewTrailingPadding)
        ])
    }

    func makeAccessible() {
        entryTextView.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                switch viewState {
                case .displayingView:
                    self?.configureDefaultViewState()
                case .savingTextEntry, .updatingTextEntry:
                    self?.disableTextView()
                case .error(_):
                    self?.enableTextView()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

extension AddEditTextEntryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.entryText = textView.text
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .label

        if viewModel.entryText.isEmpty {
            textView.text = ""
        }
    }
}
