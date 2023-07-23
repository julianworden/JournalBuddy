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
        let mockDatabaseService = MockDatabaseService()
        sut = NewTextEntryViewModel(databaseService: mockDatabaseService)
    }

    override func tearDown() {
        sut = nil
        cancellables = []
    }

    func test_OnSaveTextEntry_SavedEntryPropertyIsNotNil() {
        let expectation = XCTestExpectation(description: "savedEntry property updated with value.")

        sut.entryText = "What a great day!"
        sut.saveTextEntry()

        sut.$savedEntry
            .dropFirst()
            .sink { textEntry in
                guard textEntry != nil else {
                    XCTFail("Nil value received.")
                    return
                }

                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
