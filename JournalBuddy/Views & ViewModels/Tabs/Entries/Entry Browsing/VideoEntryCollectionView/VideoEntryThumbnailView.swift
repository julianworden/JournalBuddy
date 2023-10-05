//
//  VideoEntryThumbnailView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/22/23.
//

import Foundation
import UIKit

class VideoEntryThumbnailView: UIImageView {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var dateLabel = UILabel()
    
    var fetchImageTask: Task<Void, Never>?

    func fetchImage(for videoEntry: VideoEntry) {
        image = nil
        
        if let fetchImageTask {
            fetchImageTask.cancel()
        }
        
        if let imageFromCache = CacheService.shared.getImageFromImageCache(withURL: videoEntry.thumbnailDownloadURL) {
            configure(with: imageFromCache, and: videoEntry)
            return
        }
        
        presentActivityIndicator()

        fetchImageTask = getFetchImageTask(for: videoEntry)
    }
    
    /// Starts the `Task` for fetching a given video entry's thumbnail.
    /// - Parameter videoEntry: The video entry whose thumbnail should be fetched.
    /// - Returns: The task that is responsible for fetching and validating the image, configuring the view, and caching the image.
    /// This `Task` is stored in the class so that it can be cancelled during dequeuing to avoid data races.
    private func getFetchImageTask(for videoEntry: VideoEntry) -> Task<Void, Never> {
        return Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: URL(string: videoEntry.thumbnailDownloadURL)!)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("❌ Bad status code.")
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    print("❌ UIImage decoding error occurred.")
                    return
                }
                
                CacheService.shared.addImageToImageCache(image: image, url: videoEntry.thumbnailDownloadURL)
                
                configure(with: image, and: videoEntry)
                
                activityIndicator.stopAnimating()
            } catch {
                let error = error as NSError
                
                // Cancelling to avoid data races is normal, no need
                // to show error when cancelling occurs
                if error.code != NSURLErrorCancelled {
                    print("❌ URLSession Failed")
                    print(error.emojiMessage)
                }
            }
        }
    }
    
    func configure(with image: UIImage, and videoEntry: VideoEntry) {
        self.image = image
        
        dateLabel.text = videoEntry.unixDate.unixDateAsDate.timeOmittedNumericDateString
        dateLabel.font = UIFontMetrics.avenirNextBoldFootnote
        dateLabel.textColor = .background
        
        addConstrainedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2)
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
