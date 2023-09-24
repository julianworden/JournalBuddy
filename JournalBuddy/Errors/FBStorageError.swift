//
//  FBStorageError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/5/23.
//

import Foundation

enum FBStorageError: LocalizedError {
    case uploadDataFailed(systemError: String)
    case deleteDataFailed(systemError: String)
    
    var errorDescription: String? {
        switch self {
        case .uploadDataFailed(let systemError):
            return "Failed to upload data, please try again. System error: \(systemError)"
        case .deleteDataFailed(let systemError):
            return "Failed to delete data, please try again. System error: \(systemError)"
        }
    }
}
