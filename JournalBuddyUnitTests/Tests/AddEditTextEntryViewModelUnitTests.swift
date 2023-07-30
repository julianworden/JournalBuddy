//
//  AddEditTextEntryViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

import Combine
@testable import JournalBuddy
import XCTest

@MainActor
final class AddEditTextEntryViewModelUnitTests: XCTestCase {
    var sut: AddEditTextEntryViewModel!
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        sut = nil
        cancellables = []
    }

    func test_OnInitWithNilTextEntryToEdit_DefaultValuesAreCorrect() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertTrue(sut.entryText.isEmpty)
        XCTAssertNil(sut.textEntryToEdit)
    }

    func test_OnInitWithTextEntryToEdit_DefaultValuesAreCorrect() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertEqual(sut.entryText, sut.textEntryToEdit?.text)
        XCTAssertEqual(sut.textEntryToEdit, TextEntry.example)
    }

    func test_EntryTextViewDefaultText_ReturnsExpectedValueWithTextEntryToEdit() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )

        XCTAssertEqual(sut.entryTextViewDefaultText, sut.textEntryToEdit?.text)
    }

    func test_EntryTextViewDefaultText_ReturnsExpectedValueWithNoTextEntryToEdit() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )

        XCTAssertEqual(sut.entryTextViewDefaultText, "Tap anywhere to begin writing...")
    }

    func test_EntryTextViewDefaultTextColor_ReturnsSecondaryLabelWhenExpected() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )

        XCTAssertEqual(sut.entryTextViewDefaultTextColor, .secondaryLabel)
    }

    func test_EntryTextViewDefaultTextColor_ReturnsLabelWhenExpected() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )

        XCTAssertEqual(sut.entryTextViewDefaultTextColor, .label)
    }

    func test_EntryIsEmpty_ReturnsTrueWhenExpected() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )
        sut.entryText = "    "

        XCTAssertTrue(sut.entryIsEmpty)
    }

    func test_EntryIsEmpty_ReturnsFalseWhenExpected() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )
        sut.entryText = "I feel great!"

        XCTAssertFalse(sut.entryIsEmpty)
    }

    func test_EntryHasBeenEdited_ReturnsTrueWhenExpected() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )
        sut.entryText = "I feel great!"

        XCTAssertTrue(sut.entryHasBeenEdited)
    }

    func test_EntryHasBeenEdited_ReturnsFalseWhenTextEntryToEditIsNil() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )
        sut.entryText = "I feel great!"

        XCTAssertFalse(sut.entryHasBeenEdited)
    }

    func test_EntryHasBeenEdited_ReturnsFalseWhenTextEntryHaNotBeenEdited() {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )

        XCTAssertFalse(sut.entryHasBeenEdited)
    }

    func test_OnSuccessfullySaveNewTextEntry_ViewStateIsUpdated() async {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .textEntrySaved)
    }

    func test_OnUnsuccessfullySaveNewTextEntry_ViewStateIsUpdated() async {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: TestError.general),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func test_OnSaveTextEntryWithInvalidEntry_ErrorIsThrown() async {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: nil
        )

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(FormError.textEntryIsEmpty.localizedDescription))
    }

    func test_OnSuccessfullyUpdateTextEntry_ViewStateIsUpdated() async {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )
        sut.entryText = "What a terrible day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .textEntryUpdated)
    }

    func test_OnUnsuccessfullyUpdateTextEntry_ViewStateIsUpdated() async {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: TestError.general),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )
        sut.entryText = "What a terrible day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func test_OnUpdateUneditedTextEntry_ErrorIsThrown() async {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(FormError.textEntryHasNotBeenUpdated.localizedDescription))
    }

    func test_OnUpdateTextEntryWithEmptyText_ErrorIsThrown() async {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil),
            textEntryToEdit: TextEntry.example
        )
        sut.entryText = "     "

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(FormError.textEntryIsEmpty.localizedDescription))
    }
}
