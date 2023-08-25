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

    var viewState = UploadVideoViewState.displayingView
    let recordedVideoURL: URL

    init(recordedVideoURL: URL) {
        self.recordedVideoURL = recordedVideoURL

        print(recordedVideoURL.absoluteString)
    }
}
