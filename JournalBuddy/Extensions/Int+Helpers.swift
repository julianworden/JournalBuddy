//
//  Int+Helpers.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/27/23.
//

import Foundation

extension Int {
    /// Converts a number of seconds to a readable string that displays minute, and second values for that number of seconds. For example, 30 seconds
    /// will look like this: 00:30.
    var secondsAsTimerDurationString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(self)) ?? ""
    }
}
