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
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertTrue(sut.entryText.isEmpty)
        XCTAssertNil(sut.textEntryToEdit)
    }

    func test_OnInitWithTextEntryToEdit_DefaultValuesAreCorrect() {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertEqual(sut.entryText, sut.textEntryToEdit?.text)
        XCTAssertEqual(sut.textEntryToEdit, TextEntry.example)
    }

    func test_NavigationTitle_ReturnsExpectedValueWithTextEntryToEdit() {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.navigationTitle, "Edit Text Entry")
    }

    func test_NavigationTitle_ReturnsExpectedValueWithNoTextEntryToEdit() {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.navigationTitle, "New Text Entry")
    }

    func test_NavigationBarShouldHideMoreButton_ReturnsTrueWithTextEntryToEdit() {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertFalse(sut.navigationBarShouldHideMoreButton)
    }

    func test_NavigationBarShouldHideMoreButton_ReturnsFalseWithNoTextEntryToEdit() {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertTrue(sut.navigationBarShouldHideMoreButton)
    }

    func test_EntryTextViewDefaultText_ReturnsExpectedValueWithTextEntryToEdit() {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.entryTextViewDefaultText, sut.textEntryToEdit?.text)
    }

    func test_EntryTextViewDefaultText_ReturnsExpectedValueWithNoTextEntryToEdit() {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.entryTextViewDefaultText, "Tap anywhere to begin writing...")
    }

    func test_EntryTextViewDefaultTextColor_ReturnsSecondaryLabelWhenExpected() {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.entryTextViewDefaultTextColor, .textFieldPlaceholder)
    }

    func test_EntryTextViewDefaultTextColor_ReturnsLabelWhenExpected() {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.entryTextViewDefaultTextColor, .primaryElement)
    }

    func test_EntryIsEmpty_ReturnsTrueWhenExpected() {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)
        sut.entryText = "    "

        XCTAssertTrue(sut.entryIsEmpty)
    }

    func test_EntryIsEmpty_ReturnsFalseWhenExpected() {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)
        sut.entryText = "I feel great!"

        XCTAssertFalse(sut.entryIsEmpty)
    }

    func test_EntryHasBeenEdited_ReturnsTrueWhenExpected() {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)
        sut.entryText = "I feel great!"

        XCTAssertTrue(sut.entryHasBeenEdited)
    }

    func test_EntryHasBeenEdited_ReturnsFalseWhenTextEntryToEditIsNil() {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)
        sut.entryText = "I feel great!"

        XCTAssertFalse(sut.entryHasBeenEdited)
    }

    func test_EntryHasBeenEdited_ReturnsFalseWhenTextEntryHaNotBeenEdited() {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        XCTAssertFalse(sut.entryHasBeenEdited)
    }

    func test_OnSuccessfullySaveNewTextEntry_ViewStateIsUpdated() async {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .textEntrySaved)
    }

    func test_OnUnsuccessfullySaveNewTextEntry_ViewStateIsUpdated() async {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: TestError.general, authServiceError: nil)
        sut.entryText = "What a great day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func test_OnSaveTextEntryWithInvalidEntry_ErrorIsThrown() async {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(FormError.textEntryIsEmpty.localizedDescription))
    }

    func test_OnSuccessfullyUpdateTextEntry_ViewStateIsUpdated() async {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)
        sut.entryText = "What a terrible day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .updatedTextEntry)
    }

    func test_OnUnsuccessfullyUpdateTextEntry_ViewStateIsUpdated() async {
        initializeSUTWithTextEntryToEdit(databaseServiceError: TestError.general, authServiceError: nil)
        sut.entryText = "What a terrible day!"

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func test_OnUpdateUneditedTextEntry_ErrorIsThrown() async {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(FormError.textEntryHasNotBeenUpdated.localizedDescription))
    }

    func test_OnUpdateTextEntryWithEmptyText_ErrorIsThrown() async {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)
        sut.entryText = "     "

        await sut.saveTextEntry()

        XCTAssertEqual(sut.viewState, .error(FormError.textEntryIsEmpty.localizedDescription))
    }

    func test_OnSuccessfullyDeleteTextEntry_ViewStateIsUpdated() async {
        initializeSUTWithTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        await sut.deleteTextEntry()

        XCTAssertEqual(sut.viewState, .deletedTextEntry)
    }

    func test_OnDeleteTextEntryWithNoTextEntryToEdit_CorrectErrorIsThrown() async {
        initializeSUTWithNoTextEntryToEdit(databaseServiceError: nil, authServiceError: nil)

        await sut.deleteTextEntry()

        XCTAssertEqual(sut.viewState, .error(LogicError.deletingNonExistentEntry.localizedDescription))
    }

    func test_OnUnSuccessfullyDeleteTextEntry_ErrorIsThrown() async {
        initializeSUTWithTextEntryToEdit(databaseServiceError: TestError.general, authServiceError: nil)

        await sut.deleteTextEntry()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func initializeSUTWithTextEntryToEdit(databaseServiceError: Error?, authServiceError: Error?) {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            currentUser: User.example,
            textEntryToEdit: TextEntry.example
        )
    }

    func initializeSUTWithNoTextEntryToEdit(databaseServiceError: Error?, authServiceError: Error?) {
        sut = AddEditTextEntryViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError),
            currentUser: User.example,
            textEntryToEdit: nil
        )
    }
}
