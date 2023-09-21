//
//  AddEditGoalViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 9/19/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class AddEditGoalViewModelUnitTests: XCTestCase {
    var sut: AddEditGoalViewModel!
    var cancellables: Set<AnyCancellable>!
    var goalWasSavedNotificationExpectation: XCTNSNotificationExpectation!
    var savingGoalExpectation: XCTestExpectation!
    var savedGoalExpectation: XCTestExpectation!
    var updatingGoalExpectation: XCTestExpectation!
    var updatedGoalExpectation: XCTestExpectation!
    var deletingGoalExpectation: XCTestExpectation!
    var deletedGoalExpectation: XCTestExpectation!
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        goalWasSavedNotificationExpectation = XCTNSNotificationExpectation(
            name: .goalWasSaved
        )
        savingGoalExpectation = XCTestExpectation(
            description: ".goalIsSaving view state set."
        )
        savedGoalExpectation = XCTestExpectation(
            description: ".goalWasSaved view state set."
        )
        updatingGoalExpectation = XCTestExpectation(
            description: ".goalIsUpdating view state set."
        )
        updatedGoalExpectation = XCTestExpectation(
            description: ".goalWasUpdated view state set."
        )
        deletingGoalExpectation = XCTestExpectation(
            description: ".goalIsDeleting view state set."
        )
        deletedGoalExpectation = XCTestExpectation(
            description: ".goalWasDeleted view state set."
        )
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        savingGoalExpectation = nil
        savedGoalExpectation = nil
        updatingGoalExpectation = nil
        updatedGoalExpectation = nil
    }
    
    func test_OnInitWithGoalToEdit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        
        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertEqual(sut.goalToEdit, Goal.example)
        XCTAssertEqual(sut.goalName, Goal.example.name)
    }
    
    func test_OnInitWithoutGoalToEdit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: false)
        
        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertNil(sut.goalToEdit)
        XCTAssertTrue(sut.goalName.isReallyEmpty)
    }
    
    func test_NavigationTitle_IsCorrectWithGoalToEdit() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        
        XCTAssertEqual(sut.navigationTitle, "Edit Goal")
    }
    
    func test_NavigationTitle_IsCorrectWithoutGoalToEdit() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: false)
        
        XCTAssertEqual(sut.navigationTitle, "Create Goal")
    }
    
    func test_SaveButtonText_IsCorrectWithGoalToEdit() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        
        XCTAssertEqual(sut.saveButtonText, "Update")
    }
    
    func test_SaveButtonText_IsCorrectWithoutGoalToEdit() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: false)
        
        XCTAssertEqual(sut.saveButtonText, "Save")
    }
    
    func test_OnSaveButtonTapped_ViewStateIsUpdatedWhenNewGoalIsSavedAndGoalToEditIsNil() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: false)
        sut.goalName = "Go back to school"
        subscribeToViewStateUpdates()
        
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .goalIsUpdating, .goalWasUpdated:
                    XCTFail("A new goal should be getting saved, a goal is not being updated.")
                case .goalIsSaving:
                    self.savingGoalExpectation.fulfill()
                case .goalWasSaved:
                    self.savedGoalExpectation.fulfill()
                case .displayingView:
                    break
                default:
                    XCTFail("Unexpected view state set: \(viewState)")
                }
            }
            .store(in: &cancellables)
        
        await sut.saveButtonTapped()
        
        await fulfillment(
            of: [
                savingGoalExpectation,
                savedGoalExpectation,
                goalWasSavedNotificationExpectation
            ],
            timeout: 3
        )
    }
    
    func test_OnSaveButtonTapped_ViewStateIsUpdatedWhenGoalIsUpdatedWithNameChange() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        sut.goalName = "Go back to school"
        subscribeToViewStateUpdates()
        
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .goalIsSaving, .goalWasSaved:
                    XCTFail("An existing goal should be getting updated, a new goal is not being created.")
                case .goalIsUpdating:
                    self.updatingGoalExpectation.fulfill()
                case .goalWasUpdated:
                    self.updatedGoalExpectation.fulfill()
                case .displayingView:
                    break
                default:
                    XCTFail("Unexpected view state set: \(viewState)")
                }
            }
            .store(in: &cancellables)
        
        await sut.saveButtonTapped()
        
        await fulfillment(
            of: [
                updatingGoalExpectation,
                updatedGoalExpectation,
                goalWasSavedNotificationExpectation
            ],
            timeout: 3
        )
    }
    
    func test_OnSaveButtonTapped_ViewStateIsUpdatedWhenGoalIsUpdatedWithoutNameChange() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        sut.goalName = Goal.example.name
        
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .goalIsSaving, .goalWasSaved:
                    XCTFail("An existing goal should be getting updated, a new goal is not being created.")
                case .goalIsUpdating:
                    XCTFail("If the goal's name hasn't changed, there's no need for the network call.")
                case .goalWasUpdated:
                    self.updatedGoalExpectation.fulfill()
                case .displayingView:
                    break
                default:
                    XCTFail("Unexpected view state set: \(viewState)")
                }
            }
            .store(in: &cancellables)
        
        await sut.saveButtonTapped()
        
        await fulfillment(of: [updatedGoalExpectation], timeout: 3)
    }
    
    func test_OnSaveButtonTapped_ErrorViewStateIsSetWhenGoalIsSavedWithEmptyName() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: false)
        sut.goalName = "    "
        
        await sut.saveButtonTapped()
        
        XCTAssertEqual(sut.viewState, .error(message: FormError.goalNameIsEmpty.localizedDescription))
    }
    
    func test_OnSaveButtonTapped_ErrorViewStateIsSetWhenGoalIsUpdatedWithEmptyName() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        sut.goalName = "    "
        
        await sut.saveButtonTapped()
        
        XCTAssertEqual(sut.viewState, .error(message: FormError.goalNameIsEmpty.localizedDescription))
    }
    
    func test_OnSaveButtonTapped_ErrorViewStateIsSetWhenNetworkCallFails() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil, addGoalToEdit: true)
        sut.goalName = "Buy a new car"
        
        await sut.saveButtonTapped()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnDeleteGoalSuccessfully_ViewStateIsUpdatedAndNotificationIsPosted() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        subscribeToViewStateUpdates()
        
        await sut.deleteGoal(Goal.example)
        
        await fulfillment(
            of: [
                deletingGoalExpectation,
                deletedGoalExpectation
            ],
            timeout: 3
        )
    }
    
    func test_OnDeleteGoalUnsuccessfully_ViewStateIsUpdated() async {
        initializeSUT(databaseServiceError: TestError.general, authServiceError: nil, addGoalToEdit: true)
        
        await sut.deleteGoal(Goal.example)
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnPostGoalSavedNotification_NotificationIsPosted() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: false)
        let expectation = XCTNSNotificationExpectation(
            name: .goalWasSaved
        )
        
        sut.postGoalSavedNotification(for: Goal.example)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_OnPostGoalDeletedNotification_NotificationIsPosted() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil, addGoalToEdit: true)
        let expectation = XCTNSNotificationExpectation(
            name: .goalWasDeleted
        )
        
        sut.postDeletedGoalNotification(for: Goal.example)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?, addGoalToEdit: Bool) {
        sut = AddEditGoalViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            currentUser: User.example,
            goalToEdit: addGoalToEdit ? Goal.example : nil
        )
    }
    
    func subscribeToViewStateUpdates() {
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .goalIsSaving:
                    self.savingGoalExpectation.fulfill()
                case .goalWasSaved:
                    self.savedGoalExpectation.fulfill()
                case .goalIsUpdating:
                    self.updatingGoalExpectation.fulfill()
                case .goalWasUpdated:
                    self.updatedGoalExpectation.fulfill()
                case .goalIsDeleting:
                    self.deletingGoalExpectation.fulfill()
                case .goalWasDeleted:
                    self.deletedGoalExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
