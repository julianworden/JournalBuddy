//
//  FBFirestoreError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/26/23.
//

import Foundation

enum FBFirestoreError: LocalizedError {
    case saveDataFailed(systemError: String)

    var errorDescription: String? {
        switch self {
        case .saveDataFailed(let systemError):
            return "Failed to save data, please try again. System Error: \(systemError)"
        }
    }
}
