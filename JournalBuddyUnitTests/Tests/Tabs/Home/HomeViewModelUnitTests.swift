//
//  HomeViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/27/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class HomeViewModelUnitTests: XCTestCase {
    var sut: HomeViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnSuccessfulLogOut_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.logOut()

        XCTAssertEqual(sut.viewState, .userLoggedOut)
    }

    func test_OnUnsuccessfulLogOut_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: TestError.general)

        sut.logOut()

        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchThreeMostRecentlyCompletedGoalsSuccessfully_ArrayIsUpdated() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        await sut.fetchThreeMostRecentlyCompletedGoals()
        
        XCTAssertEqual(
            sut.threeMostRecentlyCompletedGoals,
            Array(TestData.goalsArray
                .filter { $0.isComplete }
                .sorted(by: { $0.unixDateCompleted! > $1.unixDateCompleted! })
                .prefix(3))
        )
        XCTAssertTrue(sut.refreshGoalsList)
    }
    
    func test_OnFetchThreeMostRecentlyCompletedGoalsUnsuccessfully_ViewStateIsSet() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        
        await sut.fetchThreeMostRecentlyCompletedGoals()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
        XCTAssertFalse(sut.refreshGoalsList)
    }
    
    func test_OnReceiveGoalWasCompletedNotification_NewlyCompletedGoalIsAddedToArray() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.threeMostRecentlyCompletedGoals = TestData.goalsArray.filter(where: { $0.isComplete }, limit: 2)
        
        sut.subscribeToPublishers()
        NotificationCenter.default.post(
            name: .goalWasCompleted,
            object: nil,
            userInfo: [NotificationConstants.completedGoal: Goal.example]
        )
        
        XCTAssertEqual(sut.threeMostRecentlyCompletedGoals.count, 3)
        XCTAssertEqual(sut.threeMostRecentlyCompletedGoals.first!, Goal.example)
        XCTAssertTrue(sut.refreshGoalsList)
    }
    
    func test_OnReceiveGoalWasCompletedNotification_ArrayCannotExceedThreeElements() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.threeMostRecentlyCompletedGoals = TestData.goalsArray.filter(where: { $0.isComplete }, limit: 3)
        
        sut.subscribeToPublishers()
        NotificationCenter.default.post(
            name: .goalWasCompleted,
            object: nil,
            userInfo: [NotificationConstants.completedGoal: Goal.example]
        )
        
        XCTAssertEqual(sut.threeMostRecentlyCompletedGoals.count, 3)
        XCTAssertEqual(sut.threeMostRecentlyCompletedGoals.first!, Goal.example)
        XCTAssertTrue(sut.refreshGoalsList)
    }
    
    func test_OnReceiveGoalWasDeletedNotification_NewlyDeletedGoalIsRemovedFromArray() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.threeMostRecentlyCompletedGoals = [Goal.example]
        sut.threeMostRecentlyCompletedGoals.append(contentsOf: TestData.goalsArray.filter(where: { $0.isComplete }, limit: 1))
        
        sut.subscribeToPublishers()
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: Goal.example]
        )
        
        XCTAssertEqual(sut.threeMostRecentlyCompletedGoals.count, 1)
        XCTAssertFalse(sut.threeMostRecentlyCompletedGoals.contains(Goal.example))
        XCTAssertTrue(sut.refreshGoalsList)
    }
    
    func test_OnReceiveGoalWasDeletedNotificationWithFilledArray_NetworkCallIsPerformedToRefillArray() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.threeMostRecentlyCompletedGoals = [Goal.example]
        sut.threeMostRecentlyCompletedGoals.append(contentsOf: TestData.goalsArray.filter(where: { $0.isComplete }, limit: 2))
        let expectation = XCTestExpectation(
            description: "threeMostRecentlyCompletedGoals array should be refilled with new data if its count was 3 before the deletion."
        )
        
        sut.subscribeToPublishers()
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: Goal.example]
        )
        sut.$threeMostRecentlyCompletedGoals
            .sink { goals in
                if goals.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        XCTAssertFalse(sut.threeMostRecentlyCompletedGoals.contains(Goal.example))
        XCTAssertTrue(sut.refreshGoalsList)
        wait(for: [expectation], timeout: 3)
    }

    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = HomeViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            currentUser: User.example
        )
    }
}
