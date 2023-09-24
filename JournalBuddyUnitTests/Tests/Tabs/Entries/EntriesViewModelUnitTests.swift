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
    var fetchingVideoEntriesExpectation: XCTestExpectation!
    var fetchedVideoEntriesExpectation: XCTestExpectation!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        fetchingTextEntriesExpectation = XCTestExpectation(
            description: ".fetchingTextEntries view state set."
        )
        fetchedTextEntriesExpectation = XCTestExpectation(
            description: ".fetchedTextEntries view state set."
        )
        fetchingVideoEntriesExpectation = XCTestExpectation(
            description: ".fetchingVideoEntries view state set."
        )
        fetchedVideoEntriesExpectation = XCTestExpectation(
            description: ".fetchedVideoEntries view state set."
        )
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        fetchingTextEntriesExpectation = nil
        fetchedTextEntriesExpectation = nil
        fetchingVideoEntriesExpectation = nil
        fetchedVideoEntriesExpectation = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertTrue(sut.videoEntries.isEmpty)
        XCTAssertFalse(sut.customMenuIsShowing)
        XCTAssertEqual(sut.viewState, .fetchingTextEntries)
    }

    func test_OnFetchTextEntriesSuccessfully_EntriesAreAssignedAndViewStateIsSet() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        await sut.fetchTextEntries()

        XCTAssertEqual(sut.textEntries, TestData.textEntryArray)
        XCTAssertEqual(sut.viewState, .fetchedTextEntries)
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
    
    func test_OnFetchVideoEntriesUnsuccessfully_ErrorViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        
        await sut.fetchVideoEntries()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
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
                case .fetchingVideoEntries:
                    self.fetchingVideoEntriesExpectation.fulfill()
                case .fetchedVideoEntries:
                    self.fetchedVideoEntriesExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
