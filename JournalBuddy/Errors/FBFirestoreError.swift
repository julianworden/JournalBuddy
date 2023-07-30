//
//  FBFirestoreError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/26/23.
//

import Foundation

enum FBFirestoreError: LocalizedError {
    case fetchDataFailed(systemError: String)
    case saveDataFailed(systemError: String)
    case updateDataFailed(systemError: String)

    var errorDescription: String? {
        switch self {
        case .fetchDataFailed(let systemError):
            return "Failed to fetch data, please try again. System Error: \(systemError)"
        case .saveDataFailed(let systemError):
            return "Failed to save data, please try again. System Error: \(systemError)"
        case .updateDataFailed(let systemError):
            return "Failed to update data, please try again. System Error: \(systemError)"
        }
    }
}
