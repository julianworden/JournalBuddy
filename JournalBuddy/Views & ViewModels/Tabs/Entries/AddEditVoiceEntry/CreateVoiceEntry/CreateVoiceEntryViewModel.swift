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
    /// Triggers updates for `CreateVoiceEntryView`'s label that shows how long the user has been recording.
    var recordingTimer: Timer?
    var recordingTimerStartDate: Date?
    /// Triggers updates for `CreateVoiceEntryView`'s timeline slider. Starts
    /// and stops when playback does.
    var playbackTimer: Timer?
    var voiceEntryHasBeenRecorded = false
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let isTesting: Bool
    let currentUser: User
    
    var voiceEntryURL: URL {
        if isTesting {
            return Bundle.main.url(
                forResource: "TestAudio",
                withExtension: "m4a"
            )!
        } else {
            return URL.documentsDirectory.appending(
                path: "voiceentry"
            ).appendingPathExtension(
                "m4a"
            )
        }
    }
    
    /// The amount of time that `recordingTimer` has been running in seconds.
    var recordingTimerDurationAsInt: Int {
        guard let recordingTimerStartDate else { return 0 }
        
        return Int(Date.now.timeIntervalSince(recordingTimerStartDate))
    }
    
    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        isTesting: Bool = false,
        currentUser: User
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.isTesting = isTesting
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
                
                #warning("Get rid of this set up, it's already been set up in AppDelegate.")
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
            voiceEntryHasBeenRecorded = true
            
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
    
    func newRecordingButtonTapped() {
        deleteLocalRecording()
        audioPlayer = nil
        voiceEntryHasBeenRecorded = false
    }
    
    func uploadVoiceEntry() async {
        do {
            viewState = .uploadingVoiceEntry
            
            let newVoiceEntry = VoiceEntry(
                id: "",
                creatorUID: currentUser.uid,
                unixDate: Date.now.timeIntervalSince1970,
                downloadURL: ""
            )
            
            try await databaseService.saveEntry(newVoiceEntry, at: voiceEntryURL)
            
            viewState = .uploadedVoiceEntry
            deleteLocalRecording()
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: VoiceEntryError.uploadingFailed.localizedDescription)
        }
    }
    
    /// Deletes the recorded voice entry from local storage to avoid taking up
    /// unnecessary space on the users' device.
    func deleteLocalRecording() {
        guard !isTesting,
              let audioRecorder else { return }
        
        let audioRecorderDidDeleteRecording = audioRecorder.deleteRecording()
        
        if !audioRecorderDidDeleteRecording {
            print("❌ Audio recorder failed to delete recording.")
        }
    }
    
    private func checkMicPermissions(completion: @escaping (Bool) -> Void) {
        audioSession.requestRecordPermission { recordPermissionGranted in
            completion(recordPermissionGranted)
        }
    }
    
    private func prepareAudioRecorderForRecording() throws {
        deleteLocalRecording()
        
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
