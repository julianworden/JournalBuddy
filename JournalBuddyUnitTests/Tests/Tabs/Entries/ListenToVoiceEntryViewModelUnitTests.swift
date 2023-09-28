//
//  ListenToVoiceEntryViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 9/28/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class ListenToVoiceEntryViewModelUnitTests: XCTestCase {
    var sut: ListenToVoiceEntryViewModel!
    var cancellables: Set<AnyCancellable>!
    var deletingVoiceEntryExpectation: XCTestExpectation!
    var deletedVoiceEntryExpectation: XCTestExpectation!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        deletingVoiceEntryExpectation = XCTestExpectation(description: ".deletingVoiceEntry view state set.")
        deletedVoiceEntryExpectation = XCTestExpectation(description: ".deletedVoiceEntry view state set.")
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        deletingVoiceEntryExpectation = nil
        deletedVoiceEntryExpectation = nil
    }
    
    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        XCTAssertEqual(sut.voiceEntry, VoiceEntry.example)
        XCTAssertNil(sut.audioPlayerPeriodicTimeObserver)
        XCTAssertEqual(sut.viewState, .fetchingVoiceEntry)
        XCTAssertFalse(sut.audioSessionHasBeenActivated)
    }
    
    func test_OnActivateAudioSession_PropertiesAreUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.activateAudioSession()
        
        XCTAssertTrue(sut.audioSessionHasBeenActivated)
    }
    
    func test_OnCleanUp_PropertiesAreUpdatedWhenAudioSessionHasBeenActivated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.audioSessionHasBeenActivated = true
        sut.audioPlayerPeriodicTimeObserver = 0

        sut.cleanUp()
        
        XCTAssertFalse(sut.audioSessionHasBeenActivated)
        XCTAssertNil(sut.audioPlayerPeriodicTimeObserver)
    }
    
    func test_OnCleanUp_PropertiesAreNotUpdatedWhenAudioSessionHasNotBeenActivated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.audioPlayerPeriodicTimeObserver = 0

        sut.cleanUp()
        
        XCTAssertFalse(sut.audioSessionHasBeenActivated)
        XCTAssertNotNil(sut.audioPlayerPeriodicTimeObserver)
    }
    
    func test_OnDeleteVoiceEntrySuccessfully_ViewStateUpdatesAndNotificationIsPosted() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        let deletedVoiceEntryNotificationExpectation = XCTNSNotificationExpectation(name: .voiceEntryWasDeleted)
        subscribeToViewStateUpdates()
        
        await sut.deleteVoiceEntry()
        
        await fulfillment(
            of: [
                deletingVoiceEntryExpectation,
                deletedVoiceEntryNotificationExpectation,
                deletedVoiceEntryExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnDeleteVoiceEntryUnsuccessfully_ViewStateUpdates() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.deleteVoiceEntry()
        
        await fulfillment(of: [deletingVoiceEntryExpectation], timeout: 3)
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = ListenToVoiceEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            voiceEntry: VoiceEntry.example
        )
    }
    
    func subscribeToViewStateUpdates() {
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .deletingVoiceEntry:
                    self.deletingVoiceEntryExpectation.fulfill()
                case .deletedVoiceEntry:
                    self.deletedVoiceEntryExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
