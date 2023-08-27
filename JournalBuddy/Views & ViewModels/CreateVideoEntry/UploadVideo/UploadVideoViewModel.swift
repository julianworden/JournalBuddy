//
//  UploadVideoViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import AVFoundation
import Foundation

@MainActor
final class UploadVideoViewModel: MainViewModel {
    lazy var videoPlayer = AVPlayer(url: recordedVideoURL)
    @Published var videoPlayerCurrentItemIsFinished = false
    /// The periodic time observer for the video player. This is created in in `UploadVideoView` and then removed
    /// after `UploadVideoViewController` disappears.
    var videoPlayerPeriodicTimeObserver: Any?

    var viewState = UploadVideoViewState.displayingView
    let recordedVideoURL: URL

    var videoPlayerCurrentItemLengthInSeconds: Double {
        guard let currentItem = videoPlayer.currentItem else {
            return 0
        }

        return currentItem.duration.seconds
    }

    init(recordedVideoURL: URL) {
        self.recordedVideoURL = recordedVideoURL
    }

    func videoPlayerPlayButtonTapped() {
        videoPlayer.play()
    }

    func videoPlayerPauseButtonTapped() {
        videoPlayer.pause()
    }

    func videoPlayerRestartButtonTapped() {
        videoPlayer.seek(to: CMTime(value: 0, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        videoPlayer.play()
    }

    func seekVideoPlayer(to newTimestamp: Double) {
        videoPlayer.seek(to: CMTime(seconds: newTimestamp, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
