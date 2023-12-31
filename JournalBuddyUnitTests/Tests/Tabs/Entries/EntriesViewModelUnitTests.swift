//
//  EntriesViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/28/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class EntriesViewModelUnitTests: XCTestCase {
    var sut: EntriesViewModel!
    var cancellables: Set<AnyCancellable>!
    var fetchingTextEntriesExpectation: XCTestExpectation!
    var fetchedTextEntriesExpectation: XCTestExpectation!
    var noTextEntriesFoundExpectation: XCTestExpectation!
    var fetchingVideoEntriesExpectation: XCTestExpectation!
    var fetchedVideoEntriesExpectation: XCTestExpectation!
    var noVideoEntriesFoundExpectation: XCTestExpectation!
    var fetchingVoiceEntriesExpectation: XCTestExpectation!
    var fetchedVoiceEntriesExpectation: XCTestExpectation!
    var noVoiceEntriesFoundExpectation: XCTestExpectation!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        fetchingTextEntriesExpectation = XCTestExpectation(
            description: ".fetchingTextEntries view state set."
        )
        fetchedTextEntriesExpectation = XCTestExpectation(
            description: ".fetchedTextEntries view state set."
        )
        noTextEntriesFoundExpectation = XCTestExpectation(
            description: ".noTextEntriesFound view state set"
        )
        fetchingVideoEntriesExpectation = XCTestExpectation(
            description: ".fetchingVideoEntries view state set."
        )
        fetchedVideoEntriesExpectation = XCTestExpectation(
            description: ".fetchedVideoEntries view state set."
        )
        noVideoEntriesFoundExpectation = XCTestExpectation(
            description: ".noVideoEntriesFound view state set."
        )
        fetchingVoiceEntriesExpectation = XCTestExpectation(
            description: ".fetchingVideoEntries view state set."
        )
        fetchedVoiceEntriesExpectation = XCTestExpectation(
            description: ".fetchedVideoEntries view state set."
        )
        noVoiceEntriesFoundExpectation = XCTestExpectation(
            description: ".noVideoEntriesFound view state set."
        )
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        fetchingTextEntriesExpectation = nil
        fetchedTextEntriesExpectation = nil
        noTextEntriesFoundExpectation = nil
        fetchingVideoEntriesExpectation = nil
        fetchedVideoEntriesExpectation = nil
        noVideoEntriesFoundExpectation = nil
        fetchingVoiceEntriesExpectation = nil
        fetchedVoiceEntriesExpectation = nil
        noVoiceEntriesFoundExpectation = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertTrue(sut.videoEntries.isEmpty)
        XCTAssertFalse(sut.customMenuIsShowing)
        XCTAssertEqual(sut.viewState, .fetchingTextEntries)
        XCTAssertFalse(sut.textEntriesQueryPerformed)
        XCTAssertFalse(sut.videoEntriesQueryPerformed)
    }
    
    func test_EntryQueryHasBeenPerformed_ReturnsTrueWhenExpected() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.textEntriesQueryPerformed = true
        
        XCTAssertTrue(sut.textEntriesQueryPerformed)
    }
    
    func test_EntryQueryHasBeenPerformed_ReturnsFalseWhenExpected() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        XCTAssertFalse(sut.textEntriesQueryPerformed)
    }

    func test_OnFetchFirstTextEntryBatchSuccessfully_EntriesAreAssignedAndViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()

        await sut.fetchFirstTextEntryBatch()

        XCTAssertEqual(sut.textEntries, Array(TestData.textEntryArray.prefix(FBConstants.textEntryBatchSize)))
        XCTAssertTrue(sut.textEntriesQueryPerformed)
        await fulfillment(of: [fetchingTextEntriesExpectation, fetchedTextEntriesExpectation], timeout: 3)
    }
    
    func test_OnFetchFirstTextEntryBatchSuccessfullyWithNoResults_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstTextEntryBatch(performEntryQuery: false)
        
        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertTrue(sut.textEntriesQueryPerformed)
        await fulfillment(
            of: [
                fetchingTextEntriesExpectation,
                noTextEntriesFoundExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }

    func test_OnFetchFirstTextEntryBatchUnsuccessfully_ErrorIsThrown() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstTextEntryBatch()

        await fulfillment(of: [fetchingTextEntriesExpectation], timeout: 3)
        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchNextTextEntryBatchSuccessfully_EntriesAreAssigned() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.textEntries.append(contentsOf: Array(TestData.textEntryArray.prefix(FBConstants.textEntryBatchSize)))
        
        await sut.fetchNextTextEntryBatch()
        
        XCTAssertEqual(sut.textEntries, TestData.textEntryArray)
    }
    
    func test_OnFetchNextTextEntryBatchUnsuccessfully_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        sut.textEntries.append(contentsOf: TestData.textEntryArray)
        
        await sut.fetchNextTextEntryBatch()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchFirstVideoEntryBatchSuccessfully_EntriesAreAssignedAndViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstVideoEntryBatch()
        
        XCTAssertEqual(sut.videoEntries, Array(TestData.videoEntryArray.prefix(FBConstants.videoEntryBatchSize)))
        XCTAssertTrue(sut.videoEntriesQueryPerformed)
        await fulfillment(
            of: [
                fetchingVideoEntriesExpectation,
                fetchedVideoEntriesExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnFetchFirstVideoEntryBatchSuccessfullyWithNoResults_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstVideoEntryBatch(performEntryQuery: false)
        
        XCTAssertTrue(sut.videoEntries.isEmpty)
        XCTAssertTrue(sut.videoEntriesQueryPerformed)
        await fulfillment(
            of: [
                fetchingVideoEntriesExpectation,
                noVideoEntriesFoundExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnFetchFirstVideoEntryBatchUnsuccessfully_ErrorViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstVideoEntryBatch()
        
        await fulfillment(of: [fetchingVideoEntriesExpectation], timeout: 3)
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchFirstVoiceEntryBatchSuccessfully_EntriesAreAssignedAndViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstVoiceEntryBatch(performEntryQuery: true)
        
        await fulfillment(
            of: [
                fetchingVoiceEntriesExpectation,
                fetchedVoiceEntriesExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
        XCTAssertEqual(sut.voiceEntries, Array(TestData.voiceEntryArray.prefix(FBConstants.voiceEntryBatchSize)))
        XCTAssertTrue(sut.voiceEntriesQueryPerformed)
    }
    
    func test_OnFetchNextVideoEntryBatchSuccessfully_EntriesAreAssigned() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.videoEntries.append(contentsOf: Array(TestData.videoEntryArray.prefix(FBConstants.videoEntryBatchSize)))
        
        await sut.fetchNextVideoEntryBatch()
        
        print(sut.videoEntries.count)
        print(TestData.videoEntryArray.count)
        
        XCTAssertEqual(sut.videoEntries, TestData.videoEntryArray)
    }
    
    func test_OnFetchNextVideoEntryBatchUnsuccessfully_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        sut.videoEntries.append(contentsOf: Array(TestData.videoEntryArray.prefix(FBConstants.videoEntryBatchSize)))
        
        await sut.fetchNextVideoEntryBatch()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchFirstVoiceEntryBatchSuccessfullyWithNoResults_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstVoiceEntryBatch(performEntryQuery: false)
        
        await fulfillment(
            of: [
                fetchingVoiceEntriesExpectation,
                noVoiceEntriesFoundExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
        XCTAssertTrue(sut.voiceEntries.isEmpty)
        XCTAssertTrue(sut.voiceEntriesQueryPerformed)
    }
    
    func test_OnFetchFirstVoiceEntryBatchUnsuccessfully_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstVoiceEntryBatch()
        
        await fulfillment(of: [fetchingVoiceEntriesExpectation], timeout: 3)
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchNextVoiceEntryBatchSucessfully_EntriesAreAssigned() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.voiceEntries.append(contentsOf: Array(TestData.voiceEntryArray.prefix(FBConstants.voiceEntryBatchSize)))
        
        await sut.fetchNextVoiceEntryBatch()
        
        XCTAssertEqual(sut.voiceEntries, TestData.voiceEntryArray)
    }
    
    func test_OnFetchNextVoiceEntryBatchUnsuccessfully_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        sut.voiceEntries.append(contentsOf: Array(TestData.voiceEntryArray.prefix(FBConstants.voiceEntryBatchSize)))
        
        await sut.fetchNextVoiceEntryBatch()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnReceiveTextEntryWasCreatedNotification_TextEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.viewState = .noTextEntriesFound
        
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .textEntryWasCreated,
            object: nil,
            userInfo: [NotificationConstants.createdTextEntry: TextEntry.example]
        )
        
        XCTAssertTrue(sut.textEntries.contains(TextEntry.example))
        XCTAssertEqual(sut.viewState, .fetchedTextEntries)
    }
    
    func test_OnReceiveTextEntryWasUpdatedNotification_TextEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.textEntries.append(TextEntry.example)
        sut.viewState = .fetchedTextEntries
        var updatedTextEntry = TextEntry.example
        updatedTextEntry.text = "Hello"
        
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .textEntryWasUpdated,
            object: nil,
            userInfo: [NotificationConstants.updatedTextEntry: updatedTextEntry]
        )
        
        XCTAssertFalse(sut.textEntries.contains(TextEntry.example))
        XCTAssertTrue(sut.textEntries.contains(updatedTextEntry))
        XCTAssertEqual(sut.textEntries.count, 1)
    }
    
    func test_OnReceiveTextEntryWasDeletedNotification_TextEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.textEntries.append(TextEntry.example)
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .textEntryWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedTextEntry: TextEntry.example]
        )
        
        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertEqual(sut.viewState, .noTextEntriesFound)
    }
    
    func test_OnReceiveVideoEntryWasCreatedNotification_VideoEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.selectedEntryType = .video
        sut.viewState = .noVideoEntriesFound
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .videoEntryWasCreated,
            object: nil,
            userInfo: [NotificationConstants.createdVideoEntry: VideoEntry.example]
        )
        
        XCTAssertTrue(sut.videoEntries.contains(VideoEntry.example))
        XCTAssertEqual(sut.viewState, .fetchedVideoEntries)
    }
    
    func test_OnReceiveVideoEntryWasDeletedNotification_VideoEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.videoEntries.append(VideoEntry.example)
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .videoEntryWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedVideoEntry: VideoEntry.example]
        )
        
        XCTAssertTrue(sut.videoEntries.isEmpty)
        XCTAssertEqual(sut.viewState, .noVideoEntriesFound)
    }
    
    func test_OnReceiveVoiceEntryWasCreatedNotification_VoiceEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.selectedEntryType = .voice
        sut.viewState = .noVoiceEntriesFound
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .voiceEntryWasCreated,
            object: nil,
            userInfo: [NotificationConstants.createdVoiceEntry: VoiceEntry.example]
        )
        
        XCTAssertTrue(sut.voiceEntries.contains(VoiceEntry.example))
        XCTAssertEqual(sut.viewState, .fetchedVoiceEntries)
    }
    
    func test_OnReceiveVoiceEntryWasDeletedNotification_VideoEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.voiceEntries.append(VoiceEntry.example)
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .voiceEntryWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedVoiceEntry: VoiceEntry.example]
        )
        
        XCTAssertTrue(sut.voiceEntries.isEmpty)
        XCTAssertEqual(sut.viewState, .noVoiceEntriesFound)
    }

    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = EntriesViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            currentUser: User.example
        )
    }
    
    func subscribeToViewStateUpdates() {
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .fetchingTextEntries:
                    self.fetchingTextEntriesExpectation.fulfill()
                case .fetchedTextEntries:
                    self.fetchedTextEntriesExpectation.fulfill()
                case .noTextEntriesFound:
                    self.noTextEntriesFoundExpectation.fulfill()
                case .fetchingVideoEntries:
                    self.fetchingVideoEntriesExpectation.fulfill()
                case .fetchedVideoEntries:
                    self.fetchedVideoEntriesExpectation.fulfill()
                case .noVideoEntriesFound:
                    self.noVideoEntriesFoundExpectation.fulfill()
                case .fetchingVoiceEntries:
                    self.fetchingVoiceEntriesExpectation.fulfill()
                case .fetchedVoiceEntries:
                    self.fetchedVoiceEntriesExpectation.fulfill()
                case .noVoiceEntriesFound:
                    self.noVoiceEntriesFoundExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
