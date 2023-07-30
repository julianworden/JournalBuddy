//
//  EntriesViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/28/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class EntriesViewModelUnitTests: XCTestCase {
    var sut: EntriesViewModel!

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = EntriesViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertEqual(sut.viewState, .fetchingEntries)
    }

    func test_OnSuccessfullyFetchTextEntries_EntriesAreAssignedAndViewStateIsSet() async {
        sut = EntriesViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        await sut.fetchTextEntries()

        XCTAssertEqual(sut.textEntries, TestData.textEntryArray)
        XCTAssertEqual(sut.viewState, .fetchedEntries)
    }

    func test_OnUnsuccessfullyFetchTextEntries_ErrorIsThrown() async {
        sut = EntriesViewModel(
            databaseService: MockDatabaseService(errorToThrow: TestError.general),
            authService: MockAuthService(errorToThrow: nil)
        )

        await sut.fetchTextEntries()

        XCTAssertTrue(sut.textEntries.isEmpty)
        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }
}
