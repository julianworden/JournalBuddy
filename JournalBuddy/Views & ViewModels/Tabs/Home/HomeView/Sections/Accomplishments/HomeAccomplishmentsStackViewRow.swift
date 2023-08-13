//
//  HomeAccomplishmentsStackViewRow.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/10/23.
//

import UIKit

class HomeAccomplishmentsStackViewRow: UIView {
    private lazy var contentStack = UIStackView(arrangedSubviews: [checkImageView, accomplishmentNameLabel])
    private lazy var accomplishmentNameLabel = UILabel()
    private lazy var checkImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: .primaryElementColor)
    private lazy var checkImageView = UIImageView(image: checkImage)
    private lazy var divider = CustomDivider()

    var viewConstraints: [NSLayoutConstraint] {
        if displayDivider {
            return [
                contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),

                divider.bottomAnchor.constraint(equalTo: bottomAnchor),
                divider.heightAnchor.constraint(equalToConstant: 1),
                divider.leadingAnchor.constraint(equalTo: leadingAnchor),
                divider.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        } else {
            return [
                contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        }
    }

    let displayDivider: Bool

    init(accomplishmentName: String, displayDivider: Bool) {
        self.displayDivider = displayDivider

        super.init(frame: .zero)

        configure(withAccomplishmentName: accomplishmentName)
        makeAccessible()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(withAccomplishmentName accomplishmentName: String) {
        contentStack.spacing = 10
        contentStack.alignment = .center

        checkImageView.setContentHuggingPriority(UILayoutPriority(999), for: .horizontal)
        checkImageView.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)

        accomplishmentNameLabel.text = accomplishmentName
        accomplishmentNameLabel.textAlignment = .left
        accomplishmentNameLabel.textColor = .primaryElement
        accomplishmentNameLabel.font = UIFontMetrics.avenirNextRegularBody
        accomplishmentNameLabel.numberOfLines = 2
    }

    func makeAccessible() {
        accomplishmentNameLabel.adjustsFontForContentSizeCategory = true
    }

    func constrain() {
        addConstrainedSubviews(contentStack, divider)

        NSLayoutConstraint.activate(viewConstraints)
    }
}
