//
//  AddEditVideoEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import AVFoundation
import Foundation
import Photos

#warning("If user has denied permission, we need to prompt them to go to settings to allow permissions.")

@MainActor
final class AddEditVideoEntryViewModel: NSObject, MainViewModel {
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureMovieFileOutput()

    var viewState = AddEditVideoEntryViewState.displayingView

    var videoCaptureIsAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)

            var isAuthorized = status == .authorized

            if !isAuthorized {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }

            return isAuthorized
        }
    }

    var audioCaptureIsAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)

            var isAuthorized = status == .authorized

            if !isAuthorized {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
            }

            return isAuthorized
        }
    }

    func setUpVideoCaptureSession() async {
        guard await videoCaptureIsAuthorized,
              await audioCaptureIsAuthorized else { return }

        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
        let audioDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)

        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
              let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice!),
              captureSession.canAddInput(videoDeviceInput),
              captureSession.canAddInput(audioDeviceInput)
              else { return }

        captureSession.addInput(videoDeviceInput)
        captureSession.addInput(audioDeviceInput)

        guard captureSession.canAddOutput(videoOutput) else { return }

        captureSession.sessionPreset = .high
        captureSession.addOutput(videoOutput)
        captureSession.commitConfiguration()
    }

    func startRecording() {
        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((Date.now.timeIntervalSince1970.formatted() as NSString).appendingPathExtension("mov")!)
        videoOutput.startRecording(to: URL(filePath: outputFilePath), recordingDelegate: self)
    }

    func stopRecording() {
        videoOutput.stopRecording()
    }
}

extension AddEditVideoEntryViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        #warning("Update View State")
    }

    #warning("Update View State in case of error")
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        Task {
            let photoLibraryAuthorizationStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            if photoLibraryAuthorizationStatus == .authorized {
                do {
                    try await PHPhotoLibrary.shared().performChanges {
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }
                } catch {
                    print(error.emojiMessage)
                }
            }
        }
    }
}
