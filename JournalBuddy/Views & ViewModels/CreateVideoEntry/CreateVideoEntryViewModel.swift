//
//  CreateVideoEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import AVFoundation
import Foundation

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
            
            var isAuthorized = (status == .authorized)
            
            if !isAuthorized {
                // This only prompts the user for access if they've never denied/disabled it before
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    var audioCaptureIsAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            
            var isAuthorized = (status == .authorized)
            
            if !isAuthorized {
                // This only prompts the user for access if they've never denied/disabled it before
                isAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
            }
            
            return isAuthorized
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
        recordingTimer?.invalidate()
        videoOutput.stopRecording()
        recordingTimerStartDate = nil
    }
    
    func switchCamera() {
        guard let currentVideoDeviceInput = videoDeviceInput else {
            viewState = .error(message: VideoEntryError.cameraSwitchingFailed.localizedDescription)
            return
        }
        
        do {
            let newVideoDevice = try getNewVideoCaptureDevice(currentVideoCaptureDevice: currentVideoDeviceInput.device)
            try configureNewCaptureSession(byRemoving: currentVideoDeviceInput, andAdding: newVideoDevice)
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Configures `captureSession` to accept input from the user's front camera and microphone.
    func configureNewCaptureSession() async {
        guard await videoCaptureIsAuthorized,
              await audioCaptureIsAuthorized else {
            viewState = .inadequatePermissions
            return
        }
        
        do {
            captureSession.beginConfiguration()
            
            let microphoneDevice = try getMicrophoneDevice()
            let frontCameraDevice = try getFrontCameraDevice()
            let videoDeviceInput = try AVCaptureDeviceInput(device: frontCameraDevice)
            let audioDeviceInput = try AVCaptureDeviceInput(device: microphoneDevice)
            addInputAndOutputToCaptureSession(audioInput: audioDeviceInput, videoInput: videoDeviceInput)
            
            captureSession.commitConfiguration()
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Reconfigures `captureSession` to accept input from a new `AVCaptureDevice `when the user switches cameras.
    /// - Parameters:
    ///   - oldVideoDeviceInput: The old video device that was being used before the user switched cameras.
    ///   - newVideoDevice: The new video device that the user is switching to.
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
    
    /// Verifies that `captureSession` can accept new `AVCaptureDeviceInput`s and, if it can, adds the given inputs to `captureSession`.
    /// - Parameters:
    ///   - audioInput: The audio device that will serve as `captureSession`'s audio input.
    ///   - videoInput: The video device that will serve as `captureSession`'s video input.
    func addInputAndOutputToCaptureSession(audioInput: AVCaptureDeviceInput, videoInput: AVCaptureDeviceInput) {
        guard captureSession.canAddInput(audioInput),
              captureSession.canAddInput(videoInput),
              captureSession.canAddOutput(videoOutput) else {
            viewState = .error(message: VideoEntryError.recordingSetupFailed.localizedDescription)
            return
        }
        
        self.videoDeviceInput = videoInput
        captureSession.addInput(audioInput)
        captureSession.addInput(videoInput)
        captureSession.addOutput(videoOutput)
    }
    
    /// Gets the front camera device associated with the user's device. Throws an error if no front camera
    /// devices can be found.
    /// - Returns: The user's front camera device. If none is found in the  `AVCaptureDevice.DiscoverySession`,
    /// the default front camera is returned.
    func getFrontCameraDevice() throws -> AVCaptureDevice {
        let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
            mediaType: .video, position: .front
        )
        
        if let videoDevice = videoDeviceDiscoverySession.devices.first {
            return videoDevice
        } else if let videoDevice = AVCaptureDevice.default(for: .video) {
            return videoDevice
        } else {
            throw VideoEntryError.noFrontCameraFound
        }
    }
    
    /// Gets the back camera device associated with the user's device. Throws an error if no back camera
    /// devices can be found.
    /// - Returns: The user's back camera device. If none is found in the  `AVCaptureDevice.DiscoverySession`,
    /// the default back camera is returned.
    func getBackCameraDevice() throws -> AVCaptureDevice {
        let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
            mediaType: .video, position: .back
        )
        
        if let videoDevice = backVideoDeviceDiscoverySession.devices.first {
            return videoDevice
        } else if let videoDevice = AVCaptureDevice.default(for: .video) {
            return videoDevice
        } else {
            throw VideoEntryError.noBackCameraFound
        }
    }
    
    /// Gets the default microphone device associated with the user's device.
    /// - Returns: The user's default microphone device.
    func getMicrophoneDevice() throws -> AVCaptureDevice {
        if let defaultMicrophone = AVCaptureDevice.default(for: .audio) {
            return defaultMicrophone
        } else {
            throw VideoEntryError.noMicrophoneFound
        }
    }
    
    /// Fetches a new video capture device when the user switches cameras.
    /// - Parameter currentVideoCaptureDevice: The front or back camera that the user was using before they switched cameras.
    /// - Returns: The front or back camera that the user is switching to.
    func getNewVideoCaptureDevice(currentVideoCaptureDevice: AVCaptureDevice) throws -> AVCaptureDevice {
        let currentPosition = currentVideoCaptureDevice.position
        let backCameraDevice = try getBackCameraDevice()
        let frontCameraDevice = try getFrontCameraDevice()
        
        switch currentPosition {
        case .unspecified, .front:
            return backCameraDevice
        case .back:
            return frontCameraDevice
        @unknown default:
            print("Unknown capture position. Defaulting to front camera.")
            return frontCameraDevice
        }
    }
    
    /// Changes the view state to push the user into UploadVideoEntryViewController when they select a video from a `UIImagePickerController` library.
    /// - Parameter videoURL: The URL of the video that the user chose.
    func userDidSelectRecordedVideo(at videoURL: URL) {
        do {
            let documentsURL = URL.documentsDirectory.appending(path: "videoentry").appendingPathExtension("mov")
            
            if FileManager.default.fileExists(atPath: documentsURL.path()) {
                try FileManager.default.removeItem(at: documentsURL)
            }
            
            try FileManager.default.copyItem(at: videoURL, to: documentsURL)
            
            viewState = .videoEntryWasSelectedOrRecorded(at: documentsURL, videoWasSelectedFromLibrary: true)
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: VideoEntryError.insufficientPermissions.localizedDescription)
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

        viewState = .videoEntryWasSelectedOrRecorded(at: outputFileURL, videoWasSelectedFromLibrary: false)
    }
}
