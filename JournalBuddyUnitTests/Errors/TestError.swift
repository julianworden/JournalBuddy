//
//  TestError.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

import Foundation

enum TestError: LocalizedError {
    case general

    var errorDescription: String? {
        switch self {
        case .general:
            return "Error thrown."
        }
    }
}
