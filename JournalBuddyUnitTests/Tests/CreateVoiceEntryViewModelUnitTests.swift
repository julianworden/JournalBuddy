//
//  CreateVoiceEntryViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 9/17/23.
//

import AVFoundation
import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class CreateVoiceEntryViewModelUnitTests: XCTestCase {
    var sut: CreateVoiceEntryViewModel!
    var testAudioPlayer: AVAudioPlayer!
    var cancellables: Set<AnyCancellable>!
    let testAudioPlayerURL = Bundle.main.url(
        forResource: "TestAudio",
        withExtension: "m4a"
    )!
    
    override func setUpWithError() throws {
        testAudioPlayer = try AVAudioPlayer(contentsOf: testAudioPlayerURL)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        testAudioPlayer = nil
        cancellables = nil
    }
    
    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertEqual(sut.voiceEntryURL, testAudioPlayerURL)
        XCTAssertNil(sut.recordingTimer)
        XCTAssertNil(sut.recordingTimerStartDate)
        XCTAssertNil(sut.playbackTimer)
        XCTAssertFalse(sut.voiceEntryHasBeenRecorded)
        XCTAssertTrue(sut.isTesting)
        XCTAssertEqual(sut.currentUser, User.example)
        XCTAssertNil(sut.audioRecorder)
        XCTAssertNil(sut.audioPlayer)
        XCTAssertEqual(sut.audioSession, AVAudioSession.sharedInstance())
    }
    
    func test_OnStartPlaying_AudioPlayerIsPlaying() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.audioPlayer = testAudioPlayer
        
        sut.startPlaying()
        
        XCTAssertTrue(sut.audioPlayer.isPlaying)
    }
    
    func test_OnPausePlaying_AudioPlayerIsPaused() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.audioPlayer = testAudioPlayer
        sut.audioPlayer.play()
        
        sut.pausePlaying()
        
        XCTAssertFalse(sut.audioPlayer.isPlaying)
    }
    
    func test_OnNewRecordingButtonTapped_PropertiesChange() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.audioPlayer = testAudioPlayer
        
        sut.newRecordingButtonTapped()
        
        XCTAssertNil(sut.audioPlayer)
        XCTAssertFalse(sut.voiceEntryHasBeenRecorded)
    }
    
    func test_OnUploadVoiceEntry_ViewStateChanges() async {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        let voiceEntryIsUploadingExpectation = XCTestExpectation()
        let voiceEntryWasUploadedExpectation = XCTestExpectation()
        
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .uploadingVoiceEntry:
                    voiceEntryIsUploadingExpectation.fulfill()
                case .uploadedVoiceEntry:
                    voiceEntryWasUploadedExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        await sut.uploadVoiceEntry()
        
        await fulfillment(
            of: [
                voiceEntryIsUploadingExpectation,
                voiceEntryWasUploadedExpectation
            ],
            timeout: 3
        )
    }
    
    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = CreateVoiceEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            isTesting: true,
            currentUser: User.example
        )
    }
}
