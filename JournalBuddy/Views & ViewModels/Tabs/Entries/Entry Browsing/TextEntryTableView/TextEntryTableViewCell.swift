//
//  TextEntryTableViewCell.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import UIKit

class TextEntryTableViewCell: UITableViewCell {
    static let reuseID = "entriesViewTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with textEntry: TextEntry) {
        var contentConfiguration = defaultContentConfiguration()
        contentConfiguration.text = textEntry.unixDateCreated.unixDateAsDate.timeOmittedNumericDateString
        contentConfiguration.textProperties.font = UIFontMetrics.avenirNextBoldBody
        contentConfiguration.textProperties.color = .primaryElement
        contentConfiguration.textProperties.numberOfLines = 0
        contentConfiguration.secondaryText = textEntry.text
        contentConfiguration.secondaryTextProperties.font = UIFontMetrics.avenirNextRegularBody
        contentConfiguration.secondaryTextProperties.color = .primaryElement
        contentConfiguration.secondaryTextProperties.numberOfLines = 3
        contentConfiguration.textProperties.adjustsFontForContentSizeCategory = true
        contentConfiguration.secondaryTextProperties.adjustsFontForContentSizeCategory = true
        accessoryView = UIImageView(image: .disclosureIndicator)
        self.contentConfiguration = contentConfiguration

        let selectedCellBackgroundView = UIView()
        selectedCellBackgroundView.backgroundColor = .groupedBackground
        selectedCellBackgroundView.clipsToBounds = true
        selectedBackgroundView = selectedCellBackgroundView
        backgroundColor = .background
    }
}
