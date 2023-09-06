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
    let type: EntryType
}
