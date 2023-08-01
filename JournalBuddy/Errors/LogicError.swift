//
//  LogicError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

import Foundation

enum LogicError: LocalizedError {
    case deletingNonExistentEntry
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .deletingNonExistentEntry:
            return "The Entry you're trying to delete has not been saved, so you cannot delete it."
        case .unknown(let errorMessage):
            return "An unknown error occurred, please try again. System Error: \(errorMessage)"
        }
    }
}
