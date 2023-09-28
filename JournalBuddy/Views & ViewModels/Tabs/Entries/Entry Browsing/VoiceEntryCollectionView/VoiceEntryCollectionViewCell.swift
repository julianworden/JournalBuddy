//
//  VoiceEntryCollectionViewCell.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/26/23.
//

import UIKit

class VoiceEntryCollectionViewCell: UICollectionViewCell {
    private lazy var microphoneImage = UIImage(
        systemName: "mic.circle.fill",
        withConfiguration: .primaryElementColor
    )
    
    private lazy var contentStack = UIStackView(arrangedSubviews: [microphoneImageView, dateLabel])
    private lazy var microphoneImageView = UIImageView(image: microphoneImage)
    private lazy var dateLabel = UILabel()
    
    static let reuseIdentifier = "VoiceEntryCollectionViewCell"
    
    func configure(with voiceEntry: VoiceEntry) {
        contentStack.axis = .vertical
        
        microphoneImageView.contentMode = .scaleAspectFit
        
        dateLabel.text = voiceEntry.unixDate.unixDateAsDate.timeOmittedNumericDateString
        dateLabel.textColor = .primaryElement
        dateLabel.font = UIFontMetrics.avenirNextBoldBody
        dateLabel.textAlignment = .center
        
        constrain()
    }
    
    func constrain() {
        contentView.addConstrainedSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
