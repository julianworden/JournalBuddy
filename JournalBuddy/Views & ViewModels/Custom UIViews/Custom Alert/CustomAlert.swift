//
//  CustomAlert.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/17/23.
//

import UIKit

class CustomAlert: UIView {
    private lazy var seeThroughBackground = UIView()
    private lazy var alertContentBackgroundBox = UIView()
    private lazy var titleAndMessageStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
    private lazy var titleLabel = UILabel()
    private lazy var messageLabel = UILabel()
    private lazy var messageButtonStackDivider = CustomDivider()
    private lazy var buttonStack = UIStackView(arrangedSubviews: buttons)

    let title: String
    let message: String
    let type: CustomAlertType
    var dismissButton: CustomAlertButton!
    var buttons = [CustomAlertButton]()

    init(title: String, message: String, type: CustomAlertType) {
        self.title = title
        self.message = message
        self.type = type

        super.init(frame: .zero)

        configure()
        makeAccessible()
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
        titleLabel.font = UIFontMetrics.avenirNextBoldBody
        titleLabel.textColor = .primaryElement

        messageLabel.text = message
        messageLabel.font = UIFontMetrics.avenirNextRegularFootnote
        messageLabel.textColor = .primaryElement
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        dismissButton = type.dismissButton
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        
        buttonStack.addArrangedSubview(dismissButton)
        buttonStack.spacing = 0
    }

    func makeAccessible() {
        titleLabel.adjustsFontForContentSizeCategory = true
        messageLabel.adjustsFontForContentSizeCategory = true
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

            alertContentBackgroundBox.centerYAnchor.constraint(equalTo: seeThroughBackground.centerYAnchor),
            alertContentBackgroundBox.centerXAnchor.constraint(equalTo: seeThroughBackground.centerXAnchor),
            alertContentBackgroundBox.widthAnchor.constraint(equalToConstant: 270),

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
            buttonStack.trailingAnchor.constraint(equalTo: alertContentBackgroundBox.trailingAnchor)
        ])
    }

    @objc func dismiss(_ button: UIButton) {
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
