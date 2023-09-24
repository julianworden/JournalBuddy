//
//  AsyncImageView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/22/23.
//

import Foundation
import UIKit

class AsyncImageView: UIImageView {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var dateLabel = UILabel()

    func fetchImage(for videoEntry: VideoEntry) {
        Task {
            do {
                presentActivityIndicator()
                
                dateLabel.text = videoEntry.unixDate.unixDateAsDate.timeOmittedNumericDateString
                dateLabel.font = UIFontMetrics.avenirNextBoldFootnote
                
                let (data, response) = try await URLSession.shared.data(from: URL(string: videoEntry.thumbnailDownloadURL)!)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    configureImageLoadingFailedView(for: videoEntry)
                    print("❌ Bad status code.")
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    configureImageLoadingFailedView(for: videoEntry)
                    print("❌ UIImage decoding error occurred.")
                    return
                }
                
                configure(with: image, and: videoEntry)
                
                activityIndicator.stopAnimating()
            } catch {
                configureImageLoadingFailedView(for: videoEntry)
                print("❌ URLSession Failed")
                print(error.emojiMessage)
            }
        }
    }
    
    func configure(with image: UIImage, and videoEntry: VideoEntry) {
        self.image = image
        
        dateLabel.textColor = .background
        
        addConstrainedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2)
        ])
    }
    
    func configureImageLoadingFailedView(for videoEntry: VideoEntry) {
        let imageLoadingFailedView = UIView()
        let cameraImageView = UIImageView(image: UIImage(systemName: "video", withConfiguration: .primaryElementColor))
        let contentStack = UIStackView(arrangedSubviews: [cameraImageView, dateLabel])
        
        activityIndicator.stopAnimating()
        
        imageLoadingFailedView.backgroundColor = .groupedBackground
        
        contentStack.axis = .vertical
        contentStack.spacing = 2
        
        cameraImageView.contentMode = .scaleAspectFit
        
        dateLabel.textColor = .primaryElement
        
        addConstrainedSubview(imageLoadingFailedView)
        imageLoadingFailedView.addConstrainedSubviews(contentStack)
        
        NSLayoutConstraint.activate([
            imageLoadingFailedView.topAnchor.constraint(equalTo: topAnchor),
            imageLoadingFailedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageLoadingFailedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageLoadingFailedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            contentStack.centerYAnchor.constraint(equalTo: imageLoadingFailedView.centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: imageLoadingFailedView.leadingAnchor),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: imageLoadingFailedView.trailingAnchor),
            contentStack.centerXAnchor.constraint(equalTo: imageLoadingFailedView.centerXAnchor),
            
            cameraImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func presentActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .primaryElement
        activityIndicator.startAnimating()
        
        addConstrainedSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
