//
//  EntriesViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class EntriesViewModelUnitTests: XCTestCase {
    var sut: NewTextEntryViewModel!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        sut = NewTextEntryViewModel(databaseService: MockDatabaseService(), authService: MockAuthService(errorToThrow: nil))
    }

    override func tearDown() {
        sut = nil
        cancellables = []
    }

    func test_OnSaveTextEntry_SavedEntryPropertyIsNotNil() {
        let expectation = XCTestExpectation(description: "savedEntry property updated with value.")

        sut.entryText = "What a great day!"
        sut.saveTextEntry()

        sut.$viewState
            .dropFirst()
            .sink { viewState in
                guard viewState == .textEntrySaved else {
                    XCTFail("viewState not modified as expected.")
                    return
                }

                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
