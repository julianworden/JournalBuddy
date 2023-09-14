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
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    
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
    }
    
    func stopRecording() {
        do {
            audioRecorder.stop()
            
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
        
        if audioPlayerDidStartPlaying {
            viewState = .error(message: VoiceEntryError.failedToStartPlaying.localizedDescription)
        }
    }
    
    func pausePlaying() {
        audioPlayer.pause()
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
