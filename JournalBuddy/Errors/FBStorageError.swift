//
//  FBStorageError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/5/23.
//

import Foundation

enum FBStorageError: LocalizedError {
    case saveDataFailed(systemError: String)
    
    var errorDescription: String? {
        switch self {
        case .saveDataFailed(let systemError):
            return "Failed to save data, please try again. System error: \(systemError)"
        }
    }
}
