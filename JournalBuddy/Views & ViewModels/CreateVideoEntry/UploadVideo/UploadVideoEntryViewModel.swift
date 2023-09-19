//
//  UploadVideoEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import AVFoundation
import Foundation
import Photos

@MainActor
final class UploadVideoEntryViewModel: MainViewModel {
    lazy var videoPlayer = AVPlayer(url: recordedVideoURL)
    /// The periodic time observer for the video player. This is created in in `UploadVideoView` and then removed
    /// after `UploadVideoViewController` disappears.
    var videoPlayerPeriodicTimeObserver: Any?
    
    @Published var viewState = UploadVideoEntryViewState.displayingView
    var saveVideoToDevice = false

    let isTesting: Bool
    let recordedVideoURL: URL
    /// Indicates whether or not the user is uploading a video entry directly from their photo library or not.
    let videoWasSelectedFromLibrary: Bool
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol

    var videoPlayerCurrentItemLengthInSeconds: Double {
        guard let currentItem = videoPlayer.currentItem else {
            return 0
        }

        return currentItem.duration.seconds
    }

    init(
        isTesting: Bool = false,
        recordedVideoURL: URL,
        videoWasSelectedFromLibrary: Bool,
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol
    ) {
        self.isTesting = isTesting
        self.recordedVideoURL = recordedVideoURL
        self.videoWasSelectedFromLibrary = videoWasSelectedFromLibrary
        self.databaseService = databaseService
        self.authService = authService
    }

    func videoPlayerPlayButtonTapped() {
        videoPlayer.play()
    }

    func videoPlayerPauseButtonTapped() {
        videoPlayer.pause()
    }

    func videoPlayerRestartButtonTapped() {
        videoPlayer.seek(
            to: CMTime(value: 0, timescale: 1),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
        videoPlayer.play()
    }

    func seekVideoPlayer(to newTimestamp: Double) async {
        await videoPlayer.seek(
            to: CMTime(value: CMTimeValue(newTimestamp), timescale: 1),
            toleranceBefore: CMTime(value: 1, timescale: 2),
            toleranceAfter: CMTime(value: 1, timescale: 2)
        )
    }
    
    func uploadButtonTapped(photoLibrary: PHPhotoLibraryProtocol = PHPhotoLibrary.shared()) async {
        do {
            if saveVideoToDevice {
                try await saveVideoToDevice(photoLibrary: photoLibrary)
            }
            
            try await uploadVideo()
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    private func uploadVideo() async throws {
        viewState = .videoEntryIsUploading
        
        let newVideoEntry = VideoEntry(
            id: "",
            creatorUID: authService.currentUserUID,
            unixDate: Date.now.timeIntervalSince1970,
            downloadURL: "",
            thumbnailDownloadURL: ""
        )
        
        try await databaseService.saveEntry(newVideoEntry, at: recordedVideoURL)
        
        viewState = .videoEntryWasUploaded
        deleteLocalRecording()
    }
    
    private func saveVideoToDevice(
        photoLibrary: PHPhotoLibraryProtocol = PHPhotoLibrary.shared()
    ) async throws {
        viewState = .videoEntryIsSavingToDevice
        
        try await photoLibrary.performChanges { [weak self] in
            guard let self else { return }

            PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: self.recordedVideoURL, options: nil)
        }
        
        viewState = .videoEntryWasSavedToDevice
    }
    
    /// Deletes the recorded video entry from local storage to avoid taking up
    /// unnecessary space on the users' device.
    func deleteLocalRecording() {
        guard !isTesting else { return }
        
        do {
            try FileManager.default.removeItem(at: recordedVideoURL)
        } catch {
            print(error.emojiMessage)
        }
    }
}
