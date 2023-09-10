//
//  CustomAlertType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/17/23.
//

import Foundation

enum CustomAlertType {
    case error
    case confirmation(confirmedWork: () async -> Void)
    case inadequatePermissions(dismissWork: () -> Void)

    var dismissButton: CustomAlertButton {
        switch self {
        case .error:
            return CustomAlertButton(text: "OK")
        case .confirmation(_):
            return CustomAlertButton(text: "Cancel")
        case .inadequatePermissions(_):
            return CustomAlertButton(text: "Cancel")
        }
    }
}
