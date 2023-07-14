//
//  YourLatestEntriesCollectionViewCell.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/12/23.
//

import UIKit

class HomeYourLatestEntriesCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "YourLatestEntriesCollectionViewCell"

    private lazy var textStack = UIStackView(arrangedSubviews: [entryNameLabel, entryTextLabel])
    private lazy var entryNameLabel = UILabel()
    private lazy var entryTextLabel = UILabel()
    private lazy var moreButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with entry: Entry) {
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .center

        entryNameLabel.text = entry.name
        entryNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .boldBody)
        entryNameLabel.textColor = .white
        entryNameLabel.textAlignment = .center

        let entryTextAttributedString = NSMutableAttributedString(string: entry.text)
        let entryTextParagraphStyle = NSMutableParagraphStyle()
        entryTextParagraphStyle.lineSpacing = 4
        entryTextAttributedString.addAttribute(.paragraphStyle, value: entryTextParagraphStyle, range: NSRange(location: 0, length: entryTextAttributedString.length))
        entryTextLabel.attributedText = entryTextAttributedString
        entryTextLabel.numberOfLines = 3
        entryTextLabel.textColor = .white
        entryTextLabel.textAlignment = .center
        entryTextLabel.font = .preferredFont(forTextStyle: .body)

        let moreAttributedString = NSMutableAttributedString(string: "More >")
        moreAttributedString.addAttribute(.underlineStyle, value: 1, range: NSRange(location: 0, length: moreAttributedString.length))
        moreButton.setAttributedTitle(moreAttributedString, for: .normal)
        moreButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        moreButton.titleLabel?.textColor = .white

        makeAccessible()
        constrain()
    }

    func constrain() {
        addConstrainedSubviews(textStack, moreButton)

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor),

            moreButton.trailingAnchor.constraint(equalTo: textStack.trailingAnchor, constant: -4),
            moreButton.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: -2)
        ])
    }

    func makeAccessible() {
        entryNameLabel.adjustsFontForContentSizeCategory = true
        entryTextLabel.adjustsFontForContentSizeCategory = true
    }
}
