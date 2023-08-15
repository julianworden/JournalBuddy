//
//  CustomMenu.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import UIKit

class CustomMenu: UIView {
    /// The `CustomMenuRow`s that will show each row in the `CustomMenu`.
    private lazy var rowStack = UIStackView()

    var isAnimating = false

    init(rows: [CustomMenuRow]) {
        super.init(frame: .zero)

        for row in rows {
            rowStack.addArrangedSubview(row)
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

        rowStack.axis = .vertical
        rowStack.spacing = 0
        rowStack.distribution = .fillEqually
    }


    func constrain() {
        addConstrainedSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    /// Presents `CustomMenu` with a spring animation.
    /// - Parameter completion: Code to run after the menu has finished presenting itself. Called when the spring animation finishes.
    func present(completion: @escaping () -> Void) {
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

    /// Dismisses `CustomMenu` with a spring animation.
    /// - Parameter completion: Code to run after the menu has finished dimissing itself. Called when the dismissal animation completes.
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
}
