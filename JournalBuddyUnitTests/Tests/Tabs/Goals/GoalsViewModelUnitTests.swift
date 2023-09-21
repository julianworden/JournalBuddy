//
//  GoalsViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 8/13/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class GoalsViewModelUnitTests: XCTestCase {
    var sut: GoalsViewModel!
    var fetchingGoalsExpectation: XCTestExpectation!
    var fetchedGoalsExpectation: XCTestExpectation!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        fetchingGoalsExpectation = XCTestExpectation(description: ".fetchingGoals view state set.")
        fetchedGoalsExpectation = XCTestExpectation(description: ".fetchedGoals view state set.")
    }

    override func tearDown() {
        sut = nil
        fetchingGoalsExpectation = nil
        fetchedGoalsExpectation = nil
        cancellables = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        XCTAssertEqual(sut.viewState, .fetchingGoals)
        XCTAssertTrue(sut.goals.isEmpty)
        XCTAssertTrue(sut.incompleteGoals.isEmpty)
        XCTAssertTrue(sut.completeGoals.isEmpty)
        XCTAssertEqual(sut.currentlyDisplayingGoalType, GoalsViewModel.GoalType.incomplete)
        XCTAssert(sut.cancellables.isEmpty)
    }
    
    func test_OnFetchGoalsSuccessfully_PropertiesUpdate() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchGoals()
        
        XCTAssertEqual(sut.goals, TestData.goalsArray)
        XCTAssertEqual(sut.incompleteGoals.count, 3)
        XCTAssertEqual(sut.completeGoals.count, 2)
        await fulfillment(of: [fetchingGoalsExpectation, fetchedGoalsExpectation], timeout: 3)
    }
    
    func test_OnFetchGoalsSuccessfully_CompleteGoalsAreComplete() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        await sut.fetchGoals()
        
        for goal in sut.completeGoals {
            XCTAssertTrue(goal.isComplete)
        }
    }
    
    func test_OnFetchGoalsSuccessfully_IncompleteGoalsAreComplete() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        await sut.fetchGoals()
        
        for goal in sut.incompleteGoals {
            XCTAssertFalse(goal.isComplete)
        }
    }
    
    func test_OnFetchGoalsUnsuccessfully_ViewStateChanges() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)

        await sut.fetchGoals()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnCompleteGoal_ArraysUpdate() async throws {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        
        try await sut.completeGoal(Goal.example)
        
        XCTAssertFalse(sut.incompleteGoals.contains(Goal.example))
        XCTAssertTrue(sut.completeGoals.contains(completedExampleGoal))
        XCTAssertTrue(sut.completeGoals.first!.isComplete)
    }
    
    func test_OnDeleteIncompleteGoalSuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        await sut.deleteGoal(Goal.example)
        
        XCTAssertFalse(sut.incompleteGoals.contains(Goal.example))
    }
    
    func test_OnDeleteCompleteGoalSuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        sut.completeGoals.append(completedExampleGoal)
        
        await sut.deleteGoal(completedExampleGoal)
        
        XCTAssertFalse(sut.completeGoals.contains(completedExampleGoal))
    }
    
    func test_OnDeleteGoalUnsuccessfully_ViewStateUpdates() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        await sut.deleteGoal(Goal.example)
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnReceiveGoalWasSavedNotificationForIncompleteGoal_ArrayIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        let expectation = XCTestExpectation(description: "Incomplete goal added to incompleteGoals array.")
        
        sut.subscribeToPublishers()
        sut.$incompleteGoals
            .sink { goals in
                if goals.last == Goal.example && goals.count == 1  {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.post(
            name: .goalWasSaved,
            object: nil,
            userInfo: [NotificationConstants.savedGoal: Goal.example]
        )
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_OnReceiveGoalWasSavedNotificationForCompleteGoal_ArrayIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        let expectation = XCTestExpectation(description: "Complete goal added to completeGoals array.")
        
        sut.subscribeToPublishers()
        sut.$completeGoals
            .sink { goals in
                if goals.last == completedExampleGoal && goals.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.post(
            name: .goalWasSaved,
            object: nil,
            userInfo: [NotificationConstants.savedGoal: completedExampleGoal]
        )
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_OnReceiveGoalWasDeletedNotificationForIncompleteGoal_ArrayIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        let expectation = XCTestExpectation(description: "Incomplete goal removed from incompleteGoals array.")
        
        sut.subscribeToPublishers()
        sut.$incompleteGoals
            .sink { goals in
                if !goals.contains(Goal.example) && goals.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: Goal.example]
        )
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_OnReceiveGoalWasDeletedNotificationForCompleteGoal_ArrayIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        sut.completeGoals.append(completedExampleGoal)
        let expectation = XCTestExpectation(description: "Complete goal removed from completeGoals array.")
        
        sut.subscribeToPublishers()
        sut.$completeGoals
            .sink { goals in
                if !goals.contains(completedExampleGoal) && goals.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: completedExampleGoal]
        )
        
        wait(for: [expectation], timeout: 3)
    }
    
    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = GoalsViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            currentUser: User.example
        )
    }
    
    func subscribeToViewStateUpdates() {
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .fetchingGoals:
                    self.fetchingGoalsExpectation.fulfill()
                case .fetchedGoals:
                    self.fetchedGoalsExpectation.fulfill()
                default:
                    XCTFail("Unexpected view state set.")
                }
            }
            .store(in: &cancellables)
    }
}
