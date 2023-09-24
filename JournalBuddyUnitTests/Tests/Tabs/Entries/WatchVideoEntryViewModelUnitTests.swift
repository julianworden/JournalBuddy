//
//  WatchVideoEntryViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 9/24/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class WatchVideoEntryViewModelUnitTests: XCTestCase {
    var sut: WatchVideoEntryViewModel!
    var cancellables: Set<AnyCancellable>!
    var deletingVideoEntryExpectation: XCTestExpectation!
    var deletedVideoEntryExpectation: XCTestExpectation!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        deletingVideoEntryExpectation = XCTestExpectation(description: "deletingVideoEntry view state set.")
        deletedVideoEntryExpectation = XCTestExpectation(description: "deletedVideoEntry view state set.")
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        deletingVideoEntryExpectation = nil
        deletedVideoEntryExpectation = nil
    }
    
    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        
        XCTAssertEqual(sut.viewState, .displayingView)
    }
    
    func test_OnDeleteVideoEntrySuccessfully_ViewStateUpdates() async {
        initializeSUT(
            databaseServiceError: nil,
            authServiceError: nil
        )
        subscribeToViewStateUpdates()
        
        await sut.deleteVideoEntry()
        
        await fulfillment(
            of: [
                deletingVideoEntryExpectation,
                deletedVideoEntryExpectation
            ],
            timeout: 3
        )
    }
    
    func test_OnDeleteVideoEntryUnsuccessfully_ViewStateUpdates() async {
        initializeSUT(
            databaseServiceError: TestError.general,
            authServiceError: nil
        )
        
        await sut.deleteVideoEntry()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnPostDeletedVideoEntryNotification_NotificationIsPosted() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        let expectation = XCTNSNotificationExpectation(name: .videoEntryWasDeleted)
        
        sut.postDeletedVideoEntryNotification()
        
        wait(for: [expectation], timeout: 3)
    }
    
    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = WatchVideoEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            videoEntry: VideoEntry.example
        )
    }
    
    func subscribeToViewStateUpdates() {
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .deletingVideoEntry:
                    self.deletingVideoEntryExpectation.fulfill()
                case .deletedVideoEntry:
                    self.deletedVideoEntryExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
