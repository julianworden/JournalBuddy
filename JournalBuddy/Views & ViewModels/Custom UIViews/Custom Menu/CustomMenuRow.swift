//
//  CustomMenuRow.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import Combine
import UIKit

class CustomMenuRow: UIView {
    private lazy var actionButton = UIButton()
    private lazy var divider = CustomDivider()
    private lazy var contentStack = UIStackView(arrangedSubviews: [titleLabel, iconImageView])
    private lazy var titleLabel = UILabel()
    private lazy var iconImageView = UIImageView()

    let title: String
    let iconName: String
    let displayDivider: Bool
    var cancellables = Set<AnyCancellable>()

    private var dividerHeight: CGFloat {
        displayDivider ? 1 : 0
    }

    init(title: String, iconName: String, displayDivider: Bool, target: Any?, action: Selector) {
        self.title = title
        self.iconName = iconName
        self.displayDivider = displayDivider

        super.init(frame: .zero)

        actionButton.addTarget(target, action: action, for: .touchUpInside)
        configure()
        makeAccessible()
        subscribeToPublishers()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        actionButton.tintColor = .groupedBackground

        contentStack.alignment = .center
        contentStack.spacing = 60
        contentStack.isUserInteractionEnabled = false

        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.font = UIFontMetrics.avenirNextRegularBody
        titleLabel.textColor = .primaryElement
        titleLabel.numberOfLines = 0

        iconImageView.image = UIImage(systemName: iconName, withConfiguration: .primaryElementColor)
        iconImageView.contentMode = .scaleAspectFit
    }

    func makeAccessible() {
        titleLabel.adjustsFontForContentSizeCategory = true

        adjustLayoutIfNeeded()
    }

    func subscribeToPublishers() {
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] _ in
                self?.adjustLayoutIfNeeded()
            }
            .store(in: &cancellables)
    }

    func adjustLayoutIfNeeded() {
        iconImageView.isHidden = UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium
    }

    func constrain() {
        addConstrainedSubview(actionButton)
        actionButton.addConstrainedSubviews(contentStack, divider)

        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: actionButton.topAnchor, constant: 10),
            contentStack.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -10),
            contentStack.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: 15),
            contentStack.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: -15),

            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),

            divider.bottomAnchor.constraint(equalTo: actionButton.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: dividerHeight),
            divider.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor),
        ])
    }

    @objc func buttonTapped() {
        print("Tapped!")
    }
}
