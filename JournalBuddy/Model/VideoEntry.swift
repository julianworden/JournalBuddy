//
//  VideoEntry.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/5/23.
//

import Foundation

struct VideoEntry: Entry {
    var id: String
    let creatorUID: String
    let unixDate: Double
    /// The URL at which `self` can be downloaded.
    var downloadURL: String
    var thumbnailDownloadURL: String
    let type: EntryType
    
    init(
        id: String,
        creatorUID: String,
        unixDate: Double,
        downloadURL: String,
        thumbnailDownloadURL: String,
        type: EntryType = .video
    ) {
        self.id = id
        self.creatorUID = creatorUID
        self.unixDate = unixDate
        self.downloadURL = downloadURL
        self.thumbnailDownloadURL = thumbnailDownloadURL
        self.type = type
    }
}
