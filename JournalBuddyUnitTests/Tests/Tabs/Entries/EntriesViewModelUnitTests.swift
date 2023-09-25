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

    func test_OnFetchTextEntriesSuccessfully_EntriesAreAssignedAndViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()

        await sut.fetchTextEntries()

        XCTAssertEqual(sut.textEntries, TestData.textEntryArray)
        await fulfillment(of: [fetchingTextEntriesExpectation, fetchedTextEntriesExpectation], timeout: 3)
    }
    
    func test_OnFetchTextEntriesSuccessfullyWithNoResults_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchTextEntries(performEntryQuery: false)
        
        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertTrue(sut.textEntriesQueryPerformed)
        await fulfillment(of: [noTextEntriesFoundExpectation])
    }

    func test_OnFetchTextEntriesUnsuccessfully_ErrorIsThrown() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)

        await sut.fetchTextEntries()

        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchVideoEntriesSuccessfully_EntriesAreAssignedAndViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchVideoEntries()
        
        await fulfillment(
            of: [
                fetchingVideoEntriesExpectation,
                fetchedVideoEntriesExpectation
            ],
            timeout: 3
        )
    }
    
    func test_OnFetchVideoEntriesSuccessfullyWithNoResults_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchVideoEntries(performEntryQuery: false)
        
        await fulfillment(of: [noVideoEntriesFoundExpectation], timeout: 3)
    }
    
    func test_OnFetchVideoEntriesUnsuccessfully_ErrorViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        
        await sut.fetchVideoEntries()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnReceiveVideoEntryWasDeletedNotification_VideoEntriesArrayIsUpdated() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        sut.videoEntries = TestData.videoEntryArray + [VideoEntry.example]
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .videoEntryWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedVideoEntry: VideoEntry.example]
        )
        
        XCTAssertFalse(sut.videoEntries.contains(VideoEntry.example))
        XCTAssertEqual(sut.videoEntries, TestData.videoEntryArray)
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
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
