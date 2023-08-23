//
//  UploadVideoViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Foundation

@MainActor
final class UploadVideoViewModel: MainViewModel {
    var viewState = UploadVideoViewState.displayingView

    let recordedVideoURL: URL

    init(recordedVideoURL: URL) {
        self.recordedVideoURL = recordedVideoURL

        print(recordedVideoURL.absoluteString)
    }
}
