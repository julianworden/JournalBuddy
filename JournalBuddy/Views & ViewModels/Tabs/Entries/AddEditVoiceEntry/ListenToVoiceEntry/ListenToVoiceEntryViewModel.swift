//
//  ListenToVoiceEntryViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/27/23.
//

import AVFoundation

@MainActor
final class ListenToVoiceEntryViewModel: NSObject, MainViewModel {
    let audioSession = AVAudioSession.sharedInstance()
    lazy var audioPlayer = AVPlayer(url: URL(string: voiceEntry.downloadURL)!)
    var audioPlayerPeriodicTimeObserver: Any?
    
    @Published var viewState = ListenToVoiceEntryViewState.fetchingVoiceEntry
    var audioSessionHasBeenActivated = false
    
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let voiceEntry: VoiceEntry
    
    var playerCurrentItemDuration: Double {
        guard let playerCurrentItemDuration = audioPlayer.currentItem?.duration.seconds else {
            return 0
        }
        
        return playerCurrentItemDuration
    }
    
    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        voiceEntry: VoiceEntry
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.voiceEntry = voiceEntry
    }
    
    func activateAudioSession() {
        do {
            guard !audioSessionHasBeenActivated else { return }
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
            audioSessionHasBeenActivated = true
        } catch {
            print("❌ Failed to activate audio session.")
            print(error.emojiMessage)
        }
    }
    
    func cleanUp() {
        do {
            guard audioSessionHasBeenActivated else { return }
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
            audioSessionHasBeenActivated = false
            audioPlayerPeriodicTimeObserver = nil
        } catch {
            print("❌ Failed to deactivate audio session.")
            print(error.emojiMessage)
        }
    }
    
    func startPlaying() {
        activateAudioSession()
        audioPlayer.play()
    }
    
    func pausePlaying() {
        audioPlayer.pause()
    }
    
    func seekAudioPlayer(to time: CMTimeValue) async {
        await audioPlayer.seek(
            to: CMTime(value: time, timescale: 1)
        )
    }
    
    /// Deletes a given voice entry from the appropriate arrays and from Firestore.
    /// - Parameter voiceEntry: The entry to delete.
    func deleteVoiceEntry() async {
        do {
            viewState = .deletingVoiceEntry
            try await databaseService.deleteEntry(voiceEntry)
            postVoiceEntryDeletedNotification()
            viewState = .deletedVoiceEntry
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func postVoiceEntryDeletedNotification() {
        NotificationCenter.default.post(
            name: .voiceEntryWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedVoiceEntry: voiceEntry]
        )
    }
}

extension ListenToVoiceEntryViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            viewState = .error(message: VoiceEntryError.failedToStopPlaying.localizedDescription)
            return
        }
        
        viewState = .audioPlayingHasFinished
    }
}
