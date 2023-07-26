//
//  Error+emojiMessage.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/26/23.
//

import Foundation

extension Error {
    var emojiMessage: String {
        return """
        ❌ Full Error: \(self)
        ❌ Localized Description: \(self.localizedDescription)
        """
    }
}
