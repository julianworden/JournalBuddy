//
//  VoiceEntryControlButtonType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/14/23.
//

import UIKit

enum VoiceEntryControlButtonType {
    case record, play, pause, stop, restart

    var iconName: String {
        switch self {
            case .record: "mic.circle.fill"
            case .play: "play.circle.fill"
            case .pause: "pause.circle.fill"
            case .stop: "stop.circle.fill"
            case .restart: "arrow.counterclockwise.circle.fill"
        }
    }

    var image: UIImage {
        switch self {
        case .record:
            return UIImage(
                systemName: Self.record.iconName,
                withConfiguration: .createVideoViewButton
            )!
        case .play:
            return UIImage(
                systemName: Self.play.iconName,
                withConfiguration: .createVideoViewButton
            )!
        case .pause:
            return UIImage(
                    systemName: Self.pause.iconName,
                    withConfiguration: .createVideoViewButton
                )!
        case .stop:
            return UIImage(
                systemName: Self.stop.iconName,
                withConfiguration: .createVideoViewButton
            )!
        case .restart:
            return UIImage(
                systemName: Self.restart.iconName,
                withConfiguration: .createVideoViewButton
            )!
        }
    }
}
