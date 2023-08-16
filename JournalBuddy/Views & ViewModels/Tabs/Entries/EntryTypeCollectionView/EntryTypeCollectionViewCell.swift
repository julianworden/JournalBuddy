//
//  EntryTypeCollectionViewCell.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/15/23.
//

import UIKit

class EntryTypeCollectionViewCell: UICollectionViewCell {
    private lazy var entryTypeLabel = UILabel()

    func configure(with entryType: EntryType) {
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .primaryElement

        entryTypeLabel.text = entryType.pluralRawValue
        entryTypeLabel.font = UIFontMetrics.avenirNextBoldBody
        entryTypeLabel.textColor = .background
        entryTypeLabel.textAlignment = .center
        entryTypeLabel.numberOfLines = 1

        makeAccessible()
        constrain()
    }

    func makeAccessible() {
        entryTypeLabel.adjustsFontForContentSizeCategory = true
    }

    func constrain() {
        contentView.addConstrainedSubview(entryTypeLabel)

        NSLayoutConstraint.activate([
            entryTypeLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            entryTypeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            entryTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            entryTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
