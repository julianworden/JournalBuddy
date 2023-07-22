//
//  Entry.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import Foundation

protocol Entry: Codable, Identifiable {
    var id: String { get set }
    var creatorUID: String { get }
    var unixDate: Double { get }
    var type: EntryType { get }
}
