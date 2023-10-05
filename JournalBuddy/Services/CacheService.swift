//
//  CacheService.swift
//  JournalBuddy
//
//  Created by Julian Worden on 10/4/23.
//

import UIKit

final class CacheService {
    static let shared = CacheService()
    let imageCache = NSCache<NSString, UIImage>()
    
    private init() { }
    
    func getImageFromImageCache(withURL url: String) -> UIImage? {
        return imageCache.object(forKey: NSString(string: url))
    }
    
    func addImageToImageCache(image: UIImage, url: String) {
        imageCache.setObject(image, forKey: NSString(string: url))
    }
}
