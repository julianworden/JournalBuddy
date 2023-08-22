//
//  CustomAlert.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/17/23.
//

import Combine
import UIKit

class CustomAlert: UIView {
    private lazy var seeThroughBackground = UIView()
    private lazy var alertContentBackgroundBox = UIView()
    private lazy var titleAndMessageStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
    private lazy var titleLabel = UILabel()
    private lazy var messageLabel = UILabel()
    /// The divider that separates the message and title from `buttonStack`.
    private lazy var messageButtonStackDivider = CustomDivider()
    private lazy var buttonStack = UIStackView()
    /// The divider that separates buttons within `buttonStack` from each other
    private lazy var buttonStackDivider = CustomDivider()
    /// The constraints for `buttonStackDivider`, `dismissButton`, and `confirmButton`. Changed when
    /// the user's Dynamic Type font drops above or below
    var buttonStackConstraints = [NSLayoutConstraint]()

    let title: String
    let message: String
    let type: CustomAlertType
    var dismissButton: CustomAlertButton!
    var confirmButton: CustomAlertButton?
    var cancellables = Set<AnyCancellable>()

    init(title: String, message: String, type: CustomAlertType) {
        self.title = title
        self.message = message
        self.type = type

        super.init(frame: .zero)

        configure()
        makeAccessible()
        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.25, y: 1.25)

        seeThroughBackground.backgroundColor = .fullScreenDim

        alertContentBackgroundBox.clipsToBounds = true
        alertContentBackgroundBox.backgroundColor = .groupedBackground
        alertContentBackgroundBox.layer.cornerRadius = 14

        titleAndMessageStack.axis = .vertical
        titleAndMessageStack.alignment = .center
        titleAndMessageStack.spacing = 2

        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFontMetrics.avenirNextBoldBody
        titleLabel.textColor = .primaryElement
        titleLabel.numberOfLines = 0

        messageLabel.text = message
        messageLabel.font = UIFontMetrics.avenirNextRegularFootnote
        messageLabel.textColor = .primaryElement
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        dismissButton = type.dismissButton
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        buttonStack.addArrangedSubview(dismissButton)

        if case let .confirmation(confirmedWork) = type {
            configureTwoButtonStack(with: confirmedWork)
        }
    }

    func makeAccessible() {
        titleLabel.adjustsFontForContentSizeCategory = true
        messageLabel.adjustsFontForContentSizeCategory = true
    }

    func subscribeToPublishers() {
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] notification in
                let newContentSizeCategory = notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as! UIContentSizeCategory
                self?.adjustLayoutForNewPreferredContentSizeCategory(newContentSizeCategory)
            }
            .store(in: &cancellables)
    }

    func constrain() {
        addConstrainedSubview(seeThroughBackground)
        seeThroughBackground.addConstrainedSubview(alertContentBackgroundBox)
        alertContentBackgroundBox.addConstrainedSubviews(titleAndMessageStack, messageButtonStackDivider, buttonStack)

        NSLayoutConstraint.activate([
            seeThroughBackground.topAnchor.constraint(equalTo: topAnchor),
            seeThroughBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            seeThroughBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            seeThroughBackground.trailingAnchor.constraint(equalTo: trailingAnchor),

            alertContentBackgroundBox.widthAnchor.constraint(equalToConstant: 270),
            alertContentBackgroundBox.centerYAnchor.constraint(equalTo: seeThroughBackground.centerYAnchor),
            alertContentBackgroundBox.centerXAnchor.constraint(equalTo: seeThroughBackground.centerXAnchor),

            titleAndMessageStack.topAnchor.constraint(equalTo: alertContentBackgroundBox.topAnchor, constant: 15),
            titleAndMessageStack.leadingAnchor.constraint(equalTo: alertContentBackgroundBox.leadingAnchor, constant: 10),
            titleAndMessageStack.trailingAnchor.constraint(equalTo: alertContentBackgroundBox.trailingAnchor, constant: -10),

            messageButtonStackDivider.topAnchor.constraint(equalTo: titleAndMessageStack.bottomAnchor, constant: 15),
            messageButtonStackDivider.heightAnchor.constraint(equalToConstant: 1),
            messageButtonStackDivider.leadingAnchor.constraint(equalTo: alertContentBackgroundBox.leadingAnchor),
            messageButtonStackDivider.trailingAnchor.constraint(equalTo: alertContentBackgroundBox.trailingAnchor),

            buttonStack.topAnchor.constraint(equalTo: messageButtonStackDivider.bottomAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: alertContentBackgroundBox.bottomAnchor),
            buttonStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 45),
            buttonStack.leadingAnchor.constraint(equalTo: alertContentBackgroundBox.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: alertContentBackgroundBox.trailingAnchor),
        ])
    }
    
    /// Lays out and constrains the elements of `buttonStack` when it contains more than 1 `CustomAlertButton`.
    /// - Parameter confirmedWork: The work that is to be performed if the user taps `confirmButton`.
    func configureTwoButtonStack(with confirmedWork: @escaping () async -> Void) {
        let confirmButton = getConfirmButton(with: confirmedWork)
        self.confirmButton = confirmButton

        buttonStack.insertArrangedSubview(buttonStackDivider, at: 1)

        if UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium {
            layoutVerticalButtonStack(with: confirmButton)
        } else {
            layoutHorizontalButtonStack(with: confirmButton)
        }

        NSLayoutConstraint.activate(buttonStackConstraints)
    }
    
    /// Lays out and constrains elements of a vertical `buttonStack`.
    /// - Parameter confirmButton: The button that the user is to press if they confirm that they'd like to perform whatever
    /// work the button is asking about.
    func layoutVerticalButtonStack(with confirmButton: CustomAlertButton) {
        buttonStack.insertArrangedSubview(confirmButton, at: 0)
        buttonStack.insertArrangedSubview(dismissButton, at: 2)

        buttonStackConstraints = [
            dismissButton.widthAnchor.constraint(equalToConstant: UIConstants.customAlertMinimumWidth),
            buttonStackDivider.heightAnchor.constraint(equalToConstant: 1),
            confirmButton.widthAnchor.constraint(equalToConstant: UIConstants.customAlertMinimumWidth)
        ]

        buttonStack.axis = .vertical
    }

    /// Lays out and constrains elements of a horizontal `buttonStack`.
    /// - Parameter confirmButton: The button that the user is to press if they confirm that they'd like to perform whatever
    /// work the button is asking about.
    func layoutHorizontalButtonStack(with confirmButton: CustomAlertButton) {
        buttonStack.insertArrangedSubview(confirmButton, at: 2)

        buttonStackConstraints = [
            dismissButton.widthAnchor.constraint(equalToConstant: UIConstants.customAlertMinimumWidth / 2),
            buttonStackDivider.widthAnchor.constraint(equalToConstant: 1),
            confirmButton.widthAnchor.constraint(equalToConstant: (UIConstants.customAlertMinimumWidth / 2) - 1)
        ]
        buttonStack.axis = .horizontal
    }
    
    /// Creates `createButton`, which is the button that the user will tap to confirm they want to perform whatever work that
    /// the alert is askinga about.
    /// - Parameter confirmedWork: The work that is to be performed if the user taps `confirmButton`.
    /// - Returns: The button that the user will tap to confirm the work that the alert is asking about.
    func getConfirmButton(with confirmedWork: @escaping () async -> Void) -> CustomAlertButton {
        let confirmButton = CustomAlertButton(text: "Yes")
        confirmButton.setTitleColor(.destructive, for: .normal)
        confirmButton.addAction(
            UIAction(
                handler: { [weak self] _ in
                    Task {
                        await confirmedWork()
                        self?.dismiss()
                    }
                }
            ),
            for: .touchUpInside
        )

        return confirmButton
    }
    
    /// Lays out `buttonStack` in the event that the Dynamic Type size is changed to a value above or below `.accessibilityMedium`.
    func adjustLayoutForNewPreferredContentSizeCategory(_ newContentSizeCategory: UIContentSizeCategory) {
        // No need to adjust constraints and stack axis if there is no confirmButton
        guard let confirmButton else { return }

        NSLayoutConstraint.deactivate(buttonStackConstraints)

        buttonStack.insertArrangedSubview(buttonStackDivider, at: 1)

        if newContentSizeCategory >= .accessibilityMedium {
            layoutVerticalButtonStack(with: confirmButton)
        } else {
            layoutHorizontalButtonStack(with: confirmButton)
        }

        NSLayoutConstraint.activate(buttonStackConstraints)
    }
    
    /// Dismisses the currently displaying `CustomAlert`.
    @objc func dismiss() {
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                self?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.removeFromSuperview()
            }
        )
    }
}
