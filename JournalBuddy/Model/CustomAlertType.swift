//
//  CustomAlertType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/17/23.
//

import Foundation

enum CustomAlertType {
    case error, confirmation(confirmedWork: () async -> Void)

    var dismissButton: CustomAlertButton {
        switch self {
        case .error:
            return CustomAlertButton(text: "OK")
        case .confirmation(_):
            return CustomAlertButton(text: "Cancel")
        }
    }
}
