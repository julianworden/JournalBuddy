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
        XCTAssert(sut.cancellables.isEmpty)
    }
    
    func test_OnFetchGoalsSuccessfully_ViewStateChanges() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        subscribeToViewStateUpdates()
        
        await sut.fetchGoals()
        
        await fulfillment(of: [fetchingGoalsExpectation, fetchedGoalsExpectation], timeout: 3)
    }
    
    func test_OnFetchGoalsUnsuccessfully_ViewStateChanges() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil)

        await sut.fetchGoals()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnSubscribeToPublishers_SubscriberReceivesUpdates() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        
        subscribeToViewStateUpdates()
        sut.subscribeToPublishers()
        
        NotificationCenter.default.post(name: .goalWasSaved, object: nil)
        
        wait(for: [fetchingGoalsExpectation, fetchedGoalsExpectation], timeout: 3)
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
