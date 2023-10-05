//
//  VideoEntryCollectionViewCell.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/21/23.
//

import UIKit

final class VideoEntryCollectionViewCell: UICollectionViewCell {
    private lazy var imageView = VideoEntryThumbnailView()
    
    func configure(with videoEntry: VideoEntry) {
        clipsToBounds = true
        
        imageView.fetchImage(for: videoEntry)
        
        constrain()
    }
    
    func constrain() {
        contentView.addConstrainedSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
