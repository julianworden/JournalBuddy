//
//  CustomMenu.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import UIKit

class CustomMenu: UIView {
    private lazy var buttonStack = UIStackView()

    var isAnimating = false

    init(rows: [CustomMenuRow]) {
        super.init(frame: .zero)

        for row in rows {
            buttonStack.addArrangedSubview(row)
        }

        configure()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .groupedBackground
        transform = CGAffineTransform.identity.scaledBy(x: 0.0001, y: 0.0001)
        alpha = 0
        layer.cornerRadius = 12
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 1)

        buttonStack.axis = .vertical
        buttonStack.spacing = 0
        buttonStack.distribution = .fillEqually
    }

    func show(completion: @escaping () -> Void) {
        isAnimating = true

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.5,
            animations: { [weak self] in
                self?.alpha = 1
                self?.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            },
            completion: { [weak self] _ in
                self?.isAnimating = false
                completion()
            }
        )
    }

    func dismiss(completion: @escaping () -> Void) {
        isAnimating = true

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 1,
            animations: { [weak self] in
                self?.transform = CGAffineTransform.identity.scaledBy(x: 0.0001, y: 0.0001)
                self?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.isAnimating = false
                completion()
            }
        )
    }

    func constrain() {
        addConstrainedSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
