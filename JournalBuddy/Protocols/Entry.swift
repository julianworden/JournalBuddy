//
//  Entry.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import Foundation

protocol Entry: Codable, Hashable, Identifiable {
    var id: String { get }
    var creatorUID: String { get }
    var unixDateCreated: Double { get }
    var type: EntryType { get }
}
