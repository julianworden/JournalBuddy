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
    var noGoalsFoundExpectation: XCTestExpectation!
    var noIncompleteGoalsFoundExpectation: XCTestExpectation!
    var noCompleteGoalsFoundExpectation: XCTestExpectation!
    var goalWasDeletedNotificationExpectation: XCTNSNotificationExpectation!
    var goalWasCompletedNotificationExpectation: XCTNSNotificationExpectation!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        fetchingGoalsExpectation = XCTestExpectation(description: ".fetchingGoals view state set.")
        fetchedGoalsExpectation = XCTestExpectation(description: ".fetchedGoals view state set.")
        noGoalsFoundExpectation = XCTestExpectation(description: ".noGoalsFound view state set.")
        noIncompleteGoalsFoundExpectation = XCTestExpectation(description: ".noIncompleteGoalsFound view state set.")
        noCompleteGoalsFoundExpectation = XCTestExpectation(description: ".noCompleteGoalsFound view state set.")
        goalWasDeletedNotificationExpectation = XCTNSNotificationExpectation(name: .goalWasDeleted)
        goalWasCompletedNotificationExpectation = XCTNSNotificationExpectation(name: .goalWasCompleted)
    }

    override func tearDown() {
        sut = nil
        fetchingGoalsExpectation = nil
        fetchedGoalsExpectation = nil
        noGoalsFoundExpectation = nil
        noIncompleteGoalsFoundExpectation = nil
        noCompleteGoalsFoundExpectation = nil
        cancellables = nil
        goalWasDeletedNotificationExpectation = nil
        goalWasCompletedNotificationExpectation = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        XCTAssertEqual(sut.viewState, .fetchingGoals)
        XCTAssertTrue(sut.incompleteGoals.isEmpty)
        XCTAssertTrue(sut.completeGoals.isEmpty)
        XCTAssertEqual(sut.currentlyDisplayingGoalType, GoalsViewModel.GoalType.incomplete)
        XCTAssert(sut.cancellables.isEmpty)
    }
    
    func test_OnFetchFirstGoalBatchSuccessfully_PropertiesUpdate() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchFirstGoalBatch()
        
        XCTAssertEqual(
            sut.incompleteGoals,
            TestData.goalsArray
                .filter(where: { !$0.isComplete }, limit: FBConstants.goalBatchSize)
                .sorted(by: { $0.unixDateCreated > $1.unixDateCreated })
        )
        XCTAssertEqual(
            sut.completeGoals,
            TestData.goalsArray
                .filter(where: { $0.isComplete }, limit: FBConstants.goalBatchSize)
                .sorted(by: { $0.unixDateCompleted! > $1.unixDateCompleted! })
        )
        await fulfillment(of: [fetchingGoalsExpectation, fetchedGoalsExpectation], timeout: 3)
    }
    
    func test_OnFetchFirstGoalBatchSuccessfully_ViewStateIsUpdatedWhenNoGoalsAreFound() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        await sut.fetchFirstGoalBatch(performGoalQuery: false)
        
        XCTAssertEqual(sut.viewState, .noGoalsFound)
    }
    
    func test_OnFetchFirstGoalBatchSuccessfully_CompleteGoalsAreComplete() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        await sut.fetchFirstGoalBatch()
        
        guard !sut.completeGoals.isEmpty else {
            XCTFail("Complete goals should've been fetched.")
            return
        }
        
        for goal in sut.completeGoals {
            XCTAssertTrue(goal.isComplete)
        }
        
        XCTAssertTrue(sut.goalsQueryWasPerformed)
    }
    
    func test_OnFetchFirstGoalBatchSuccessfully_IncompleteGoalsAreIncomplete() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        await sut.fetchFirstGoalBatch()
        
        guard !sut.incompleteGoals.isEmpty else {
            XCTFail("Incomplete goals should've been fetched.")
            return
        }
        
        for goal in sut.incompleteGoals {
            XCTAssertFalse(goal.isComplete)
        }
        
        XCTAssertTrue(sut.goalsQueryWasPerformed)
    }
    
    func test_OnFetchFirstGoalBatchUnsuccessfully_ViewStateChanges() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)

        await sut.fetchFirstGoalBatch()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchNextIncompleteGoalBatchSuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        addFirstGoalBatchToIncompleteGoalsArray()
        
        await sut.fetchNextIncompleteGoalBatch()
        
        XCTAssertEqual(
            sut.incompleteGoals,
            TestData.goalsArray
                .filter { !$0.isComplete }
                .sorted(by: { $0.unixDateCreated > $1.unixDateCreated })
        )
    }
    
    func test_OnFetchNextIncompleteGoalBatchUnsuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        addFirstGoalBatchToIncompleteGoalsArray()
        
        await sut.fetchNextIncompleteGoalBatch()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnFetchNextCompleteGoalBatchSuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        addFirstGoalBatchToCompleteGoalsArray()
        
        await sut.fetchNextCompleteGoalBatch()
        
        XCTAssertEqual(
            sut.completeGoals,
            TestData.goalsArray
                .filter { $0.isComplete }
                .sorted(by: { $0.unixDateCompleted! > $1.unixDateCompleted! })
               
        )
        
    }
    
    func test_OnFetchNextCompleteGoalBatchUnsuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        addFirstGoalBatchToCompleteGoalsArray()
        
        await sut.fetchNextCompleteGoalBatch()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnCompleteGoal_ArraysUpdate() async throws {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        subscribeToViewStateUpdates()
        try await sut.completeGoal(Goal.example)
        
        XCTAssertEqual(sut.completeGoals.count, 1)
        XCTAssertNotNil(sut.completeGoals.first!.unixDateCompleted)
        XCTAssertTrue(sut.completeGoals.first!.isComplete)
        XCTAssertTrue(sut.incompleteGoals.isEmpty)
        await fulfillment(
            of: [
                noIncompleteGoalsFoundExpectation,
                goalWasCompletedNotificationExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnCompleteGoalThatIsAlreadyCompleted_ArraysDoNotUpdate() async throws {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        sut.completeGoals.append(completedExampleGoal)
        
        try await sut.completeGoal(completedExampleGoal)
        
        XCTAssertTrue(sut.completeGoals.contains(completedExampleGoal))
        XCTAssertTrue(sut.incompleteGoals.isEmpty)
    }
    
    func test_OnPostGoalWasCompletedNotification_NotificationIsPosted() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        sut.postGoalWasCompletedNotification(Goal.example)
        
        wait(for: [goalWasCompletedNotificationExpectation], timeout: 3)
    }
    
    func test_OnDeleteIncompleteGoalSuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        subscribeToViewStateUpdates()
        await sut.deleteGoal(Goal.example)
        
        XCTAssertFalse(sut.incompleteGoals.contains(Goal.example))
        await fulfillment(
            of: [
                noGoalsFoundExpectation,
                goalWasDeletedNotificationExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnDeleteCompleteGoalSuccessfully_ArrayUpdates() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        sut.completeGoals.append(completedExampleGoal)
        
        subscribeToViewStateUpdates()
        await sut.deleteGoal(completedExampleGoal)
        
        XCTAssertFalse(sut.completeGoals.contains(completedExampleGoal))
        await fulfillment(
            of: [
                noGoalsFoundExpectation,
                goalWasDeletedNotificationExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnDeleteGoalUnsuccessfully_ViewStateUpdates() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        await sut.deleteGoal(Goal.example)
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnPostGoalWasDeletedNotification_NotificationIsPosted() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        sut.postGoalWasDeletedNotification(Goal.example)
        
        wait(for: [goalWasDeletedNotificationExpectation], timeout: 3)
    }
    
    func test_OnReceiveGoalWasSavedNotificationForIncompleteGoal_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        subscribeToViewStateUpdates()
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .goalWasSaved,
            object: nil,
            userInfo: [NotificationConstants.savedGoal: Goal.example]
        )
        
        wait(for: [noCompleteGoalsFoundExpectation], timeout: 3)
    }
    
    func test_OnReceiveGoalWasSavedNotificationForCompleteGoal_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        
        subscribeToViewStateUpdates()
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(
            name: .goalWasSaved,
            object: nil,
            userInfo: [NotificationConstants.savedGoal: completedExampleGoal]
        )
        
        wait(for: [noIncompleteGoalsFoundExpectation], timeout: 3)
    }
    
    func test_OnReceiveGoalWasDeletedNotificationForIncompleteGoal_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        subscribeToViewStateUpdates()
        sut.subscribeToGoalWasDeletedPublisher()
        
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: Goal.example]
        )
        
        wait(for: [noGoalsFoundExpectation], timeout: 3)
    }
    
    func test_OnReceiveGoalWasDeletedNotificationForCompleteGoal_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        sut.completeGoals.append(completedExampleGoal)
        
        subscribeToViewStateUpdates()
        sut.subscribeToGoalWasDeletedPublisher()
        
        NotificationCenter.default.post(
            name: .goalWasDeleted,
            object: nil,
            userInfo: [NotificationConstants.deletedGoal: completedExampleGoal]
        )
        
        wait(for: [noGoalsFoundExpectation], timeout: 3)
    }
    
    func test_OnAddGoalToArraysWithIncompleteGoal_ArrayUpdates() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        sut.addGoalToArrays(Goal.example)
        
        XCTAssertTrue(sut.incompleteGoals.contains(Goal.example))
        XCTAssertTrue(sut.completeGoals.isEmpty)
    }
    
    func test_OnAddGoalToArraysWithCompleteGoal_ArrayUpdates() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        
        sut.addGoalToArrays(completedExampleGoal)
        
        XCTAssertTrue(sut.completeGoals.contains(completedExampleGoal))
        XCTAssertTrue(sut.incompleteGoals.isEmpty)
    }
    
    func test_OnRemoveGoalFromArrayWithIncompleteGoal_ArrayUpdates() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        sut.removeGoalFromArray(Goal.example)

        XCTAssertTrue(sut.incompleteGoals.isEmpty)
        XCTAssertTrue(sut.completeGoals.isEmpty)
    }
    
    func test_OnRemoveGoalFromArrayWithCompleteGoal_ArrayUpdates() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        var completedExampleGoal = Goal.example
        completedExampleGoal.isComplete = true
        sut.completeGoals.append(completedExampleGoal)
        
        sut.removeGoalFromArray(completedExampleGoal)
        
        XCTAssertTrue(sut.incompleteGoals.isEmpty)
        XCTAssertTrue(sut.completeGoals.isEmpty)
    }
    
    func test_OnSetViewStateWithEmptyGoalsArray_ViewStateIsSet() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        sut.setViewState()
        
        XCTAssertEqual(sut.viewState, .noGoalsFound)
    }
    
    func test_OnSetViewStateWithEmptyCompleteGoalsArray_ViewStateIsSet() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        
        sut.setViewState()
        
        XCTAssertEqual(sut.viewState, .noCompleteGoalsFound)
    }
    
    func test_OnSetViewStateWithEmptyIncompleteGoalsArray_ViewStateIsSet() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.completeGoals.append(Goal.example)
        
        sut.setViewState()
        
        XCTAssertEqual(sut.viewState, .noIncompleteGoalsFound)
    }
    
    func test_OnSetViewStateWithAllArraysFilled_ViewStateIsSet() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.incompleteGoals.append(Goal.example)
        sut.completeGoals.append(Goal.example)
        
        sut.setViewState()
        
        XCTAssertEqual(sut.viewState, .fetchedGoals)
    }
    
    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = GoalsViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            currentUser: User.example
        )
    }
    
    func addFirstGoalBatchToIncompleteGoalsArray() {
        sut.incompleteGoals = Array(
            TestData.goalsArray
                .filter({ !$0.isComplete })
                .sorted(by: { $0.unixDateCreated > $1.unixDateCreated })
                .prefix(FBConstants.goalBatchSize)
        )
    }
    
    func addFirstGoalBatchToCompleteGoalsArray() {
        sut.completeGoals = Array(
            TestData.goalsArray
                .filter({ $0.isComplete })
                .sorted(by: { $0.unixDateCompleted! > $1.unixDateCompleted! })
                .prefix(FBConstants.goalBatchSize)
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
                case .noGoalsFound:
                    self.noGoalsFoundExpectation.fulfill()
                case .noIncompleteGoalsFound:
                    self.noIncompleteGoalsFoundExpectation.fulfill()
                case .noCompleteGoalsFound:
                    self.noCompleteGoalsFoundExpectation.fulfill()
                default:
                    XCTFail("Unexpected view state set.")
                }
            }
            .store(in: &cancellables)
    }
}
