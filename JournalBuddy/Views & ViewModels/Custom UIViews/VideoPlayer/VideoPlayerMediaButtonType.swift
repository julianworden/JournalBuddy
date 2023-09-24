//
//  VideoPlayerMediaButtonType.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/25/23.
//

import UIKit

enum VideoPlayerMediaButtonType {
    case play, pause, restart

    var iconName: String {
        switch self {
        case .play:
            "play.circle.fill"
        case .pause:
            "pause.circle.fill"
        case .restart:
            "arrow.counterclockwise.circle.fill"
        }
    }

    var image: UIImage {
        switch self {
        case .play:
            return UIImage(
                systemName: VideoPlayerMediaButtonType.play.iconName,
                withConfiguration: .largeScale
            )!.withTintColor(.primaryElement)
        case .pause:
            return UIImage(
                    systemName: VideoPlayerMediaButtonType.pause.iconName,
                    withConfiguration: .largeScale
                )!.withTintColor(.primaryElement)
        case .restart:
            return UIImage(
                systemName: VideoPlayerMediaButtonType.restart.iconName,
                withConfiguration: .largeScale
            )!.withTintColor(.primaryElement)
        }
    }
}
