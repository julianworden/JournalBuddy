//
//  VideoPlayerView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/24/23.
//

import AVFoundation
import UIKit

class VideoPlayerView: UIView {
    // The associated player object.
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    init(player: AVPlayer) {
        super.init(frame: .zero)

        self.player = player
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
