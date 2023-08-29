//
//  CreateVideoEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import AVFoundation
import Foundation
import Photos

#warning("If user has denied permission, we need to prompt them to go to settings to allow permissions.")

@MainActor
final class CreateVideoEntryViewModel: NSObject, MainViewModel {
    @Published var viewState = CreateVideoEntryViewState.displayingView

    let captureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    let videoOutput = AVCaptureMovieFileOutput()
    var recordingTimerStartDate: Date?
    var recordingTimer: Timer?

    var recordingTimerDurationAsInt: Int {
        guard let recordingTimerStartDate else { return 0 }

        return Int(Date.now.timeIntervalSince(recordingTimerStartDate))
    }

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

        do {
            captureSession.beginConfiguration()
            #warning("Perform discovery session for video device here just to be safe.")
            let defaultFrontCamera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
            let defaultMicrophone = AVCaptureDevice.default(for: .audio)
            
            guard let defaultFrontCamera,
                  let defaultMicrophone else {
                viewState = .error(message: VideoRecordingError.recordingSetupFailed.localizedDescription)
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultFrontCamera)
            let audioDeviceInput = try AVCaptureDeviceInput(device: defaultMicrophone)
            
            guard captureSession.canAddInput(videoDeviceInput),
                  captureSession.canAddInput(audioDeviceInput),
                  captureSession.canAddOutput(videoOutput) else {
                viewState = .error(message: VideoRecordingError.recordingSetupFailed.localizedDescription)
                return
            }
            
            self.videoDeviceInput = videoDeviceInput
            captureSession.addInput(videoDeviceInput)
            captureSession.addInput(audioDeviceInput)
            captureSession.addOutput(videoOutput)
            
            captureSession.commitConfiguration()
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }

    func startRecording() {
        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(("recordedvideo" as NSString).appendingPathExtension("mov")!)

        do {
            if FileManager.default.fileExists(atPath: outputFilePath) {
                try FileManager.default.removeItem(atPath: outputFilePath)
            }
            
            videoOutput.startRecording(to: URL(filePath: outputFilePath), recordingDelegate: self)
            recordingTimerStartDate = Date.now
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }

    func stopRecording() {
        videoOutput.stopRecording()
        recordingTimerStartDate = nil
    }

    func switchCameraButtonTapped() {
        guard let currentVideoDeviceInput = videoDeviceInput else {
            viewState = .error(message: VideoRecordingError.cameraSwitchingFailed.localizedDescription)
            return
        }
        
        if let newVideoDevice = getNewVideoDevice(currentVideoDevice: currentVideoDeviceInput.device) {
            do {
                try configureNewCaptureSession(byRemoving: currentVideoDeviceInput, andAdding: newVideoDevice)
            } catch {
                print(error.emojiMessage)
                viewState = .error(message: VideoRecordingError.cameraSwitchingFailed.localizedDescription)
            }
        }
    }
    
    func getNewVideoDevice(currentVideoDevice: AVCaptureDevice) -> AVCaptureDevice? {
        let currentPosition = currentVideoDevice.position
        let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
            mediaType: .video, position: .back
        )
        let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
            mediaType: .video, position: .front
        )
        
        switch currentPosition {
        case .unspecified, .front:
            return backVideoDeviceDiscoverySession.devices.first
        case .back:
            return frontVideoDeviceDiscoverySession.devices.first
        @unknown default:
            print("Unknown capture position. Defaulting to back, dual-camera.")
            return AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        }
    }
    
    func configureNewCaptureSession(
        byRemoving oldVideoDeviceInput: AVCaptureDeviceInput,
        andAdding newVideoDevice: AVCaptureDevice
    ) throws {
        let newVideoDeviceInput = try AVCaptureDeviceInput(device: newVideoDevice)
        captureSession.beginConfiguration()
        captureSession.removeInput(oldVideoDeviceInput)
        
        if captureSession.canAddInput(newVideoDeviceInput) {
            captureSession.addInput(newVideoDeviceInput)
            self.videoDeviceInput = newVideoDeviceInput
        } else {
            captureSession.addInput(oldVideoDeviceInput)
            print("The current AVCaptureSession cannot add the new AVCaptureDeviceInput.")
        }
        
        if videoOutput.connection(with: .video) != nil {
            captureSession.commitConfiguration()
        }
    }
}

extension CreateVideoEntryViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        viewState = .recordingVideo
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            viewState = .error(message: error!.localizedDescription)
            print(error!.emojiMessage)
            return
        }

        viewState = .videoRecordingCompleted(at: outputFileURL)

        #warning("Move this code to view for uploading")
//        Task {
//            let photoLibraryAuthorizationStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
//            if photoLibraryAuthorizationStatus == .authorized {
//                do {
//                    try await PHPhotoLibrary.shared().performChanges {
//                        let options = PHAssetResourceCreationOptions()
//                        options.shouldMoveFile = true
//                        let creationRequest = PHAssetCreationRequest.forAsset()
//                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
//                    }
//                } catch {
//                    print(error.emojiMessage)
//                }
//            }
//        }
    }
}
