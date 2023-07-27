//
//  NewTextEntryViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class NewTextEntryViewModelUnitTests: XCTestCase {
    var sut: NewTextEntryViewModel!
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        sut = nil
        cancellables = []
    }

    func test_EntryIsValid_ReturnsFalseWhenExpected() {
        sut = NewTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )
        sut.entryText = "    "

        XCTAssertFalse(sut.entryIsValid)
    }

    func test_EntryIsValid_ReturnsTrueWhenExpected() {
        sut = NewTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )
        sut.entryText = "I feel great!"

        XCTAssertTrue(sut.entryIsValid)
    }

    func test_OnSuccessfullySaveTextEntry_ViewStateIsUpdated() async {
        sut = NewTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )
        let expectation = XCTestExpectation(description: "savedEntry property updated with value.")
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        sut.$viewState
            .sink { viewState in
                guard viewState == .textEntrySaved else {
                    XCTFail("Instead of the expected view state, \(viewState) was found.")
                    return
                }

                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 3)
    }

    func test_OnUnsuccessfullySaveTextEntry_ViewStateIsUpdated() async {
        sut = NewTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: TestError.general),
            authService: MockAuthService(errorToThrow: nil)
        )
        let expectation = XCTestExpectation(description: "savedEntry property updated with value.")
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        sut.$viewState
            .sink { viewState in
                guard viewState == .error(CustomError.unknown(TestError.general.localizedDescription).localizedDescription) else {
                    XCTFail("Instead of the expected view state, \(viewState) was found.")
                    return
                }

                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 3)
    }

    func test_OnSaveTextEntryWithInvalidEntry_ErrorIsThrown() async {
        sut = NewTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(FormError.emptyTextEntry.localizedDescription))
    }
}
