//
//  CustomError.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/25/23.
//

import Foundation

enum CustomError: LocalizedError {
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .unknown(let errorMessage):
            return "An unknown error occurred, please try again. System Error: \(errorMessage)"
        }
    }
}
