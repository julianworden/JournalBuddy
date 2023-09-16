//
//  CreateVoiceEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/13/23.
//

import Foundation
import AVFoundation

@MainActor
final class CreateVoiceEntryViewModel: NSObject, MainViewModel {
    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    @Published var viewState = CreateVoiceEntryViewState.displayingView
    let voiceEntryURL = URL.documentsDirectory.appending(path: "voiceentry").appendingPathExtension("m4a")
    /// Triggers updates for `CreateVoiceEntryView`'s label that shows how long the user has been recording.
    var recordingTimer: Timer?
    var recordingTimerStartDate: Date?
    /// Triggers updates for `CreateVoiceEntryView`'s timeline slider. Starts
    /// and stops when playback does.
    var playbackTimer: Timer?
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    
    /// The amount of time that `recordingTimer` has been running in seconds.
    var recordingTimerDurationAsInt: Int {
        guard let recordingTimerStartDate else { return 0 }
        
        return Int(Date.now.timeIntervalSince(recordingTimerStartDate))
    }
    
    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        currentUser: User
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
    }
    
    func configureAudioSession() {
        audioSession.requestRecordPermission { [weak self] permissionGranted in
            do {
                guard let self,
                      permissionGranted else {
                    self?.viewState = .inadequatePermissions
                    return
                }
                
                try self.audioSession.setCategory(.playAndRecord)
                try self.audioSession.setActive(true)
                try self.audioSession.overrideOutputAudioPort(.speaker)
                try self.prepareAudioRecorderForRecording()
            } catch {
                print(error.emojiMessage)
                self?.viewState = .error(message: VoiceEntryError.audioSessionSetupFailed.localizedDescription)
            }
        }
    }
    
    func startRecording() {
        audioRecorder.record()
        
        recordingTimerStartDate = Date.now
    }
    
    func stopRecording() {
        do {
            audioRecorder.stop()
            recordingTimer?.invalidate()
            recordingTimer = nil
            
            audioPlayer = try AVAudioPlayer(contentsOf: voiceEntryURL)
            audioPlayer.volume = 1
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: VoiceEntryError.failedToStopRecording.localizedDescription)
        }
    }
    
    func startPlaying() {
        let audioPlayerDidStartPlaying = audioPlayer.play()
        
        if !audioPlayerDidStartPlaying {
            viewState = .error(message: VoiceEntryError.failedToStartPlaying.localizedDescription)
        }
    }
    
    func pausePlaying() {
        audioPlayer.pause()
    }
    
    func restartAudioPlayer() {
        audioPlayer.play()
    }
    
    private func checkMicPermissions(completion: @escaping (Bool) -> Void) {
        audioSession.requestRecordPermission { recordPermissionGranted in
            completion(recordPermissionGranted)
        }
    }
    
    private func prepareAudioRecorderForRecording() throws {
        if FileManager.default.fileExists(atPath: voiceEntryURL.path()) {
            try FileManager.default.removeItem(at: voiceEntryURL)
        }
        
        audioRecorder = try AVAudioRecorder(
            url: URL(filePath: voiceEntryURL.path()),
            settings: [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderBitRateKey: 320_000
            ]
        )
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
    }
  
    #warning("Try this later.")
//    func getRecordingVolume() -> Float {
//        audioRecorder.updateMeters()
//        return audioRecorder.peakPower(forChannel: 1)
//    }
}

extension CreateVoiceEntryViewModel: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag else {
            viewState = .error(message: VoiceEntryError.failedToStopRecording.localizedDescription)
            return
        }
        
        viewState = .audioRecordingHasFinished
    }
}

extension CreateVoiceEntryViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            viewState = .error(message: VoiceEntryError.failedToStopPlaying.localizedDescription)
            return
        }
        
        viewState = .audioPlayingHasFinished
    }
}
