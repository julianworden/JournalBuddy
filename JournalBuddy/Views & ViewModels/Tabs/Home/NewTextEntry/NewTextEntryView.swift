//
//  NewTextEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/21/23.
//

import Combine
import UIKit

class NewTextEntryView: UIView, MainView {
    private lazy var entryTextView = UITextView()

    let viewModel: NewTextEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: NewTextEntryViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configureDefaultUI()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDefaultUI() {
        backgroundColor = .systemBackground

        entryTextView.delegate = self
        entryTextView.text = "Tap anywhere to begin writing..."
        entryTextView.font = .preferredFont(forTextStyle: .body)
        entryTextView.textColor = .secondaryLabel
        entryTextView.showsVerticalScrollIndicator = false
        entryTextView.keyboardDismissMode = .interactive
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

    }
}

extension NewTextEntryView: UITextViewDelegate {
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