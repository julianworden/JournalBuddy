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

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = NewTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertTrue(sut.entryText.isEmpty)
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
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .textEntrySaved)
    }

    func test_OnUnsuccessfullySaveTextEntry_ViewStateIsUpdated() async {
        sut = NewTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: TestError.general),
            authService: MockAuthService(errorToThrow: nil)
        )
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(CustomError.unknown(TestError.general.localizedDescription).localizedDescription))
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
