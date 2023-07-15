//
//  HomeSquareButtonType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/14/23.
//

import UIKit

enum HomeSquareButtonType {
    case text, video, voice, calendar

    var iconName: String {
        switch self {
        case .text:
            return "square.and.pencil"
        case .video:
            return "video"
        case .voice:
            return "mic"
        case .calendar:
            return "calendar"
        }
    }

    var titleLabel: String {
        switch self {
        case .text:
            return "New Text \nEntry"
        case .video:
            return "New Video \nEntry"
        case .voice:
            return "New Voice \nEntry"
        case .calendar:
            return "Your \nCalendar"
        }
    }
}
