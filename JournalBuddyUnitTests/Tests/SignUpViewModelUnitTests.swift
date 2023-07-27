//
//  SignUpViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/25/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class SignUpViewModelUnitTests: XCTestCase {
    var sut: SignUpViewModel!

    override func setUp() { }

    override func tearDown() {
        sut = nil
    }

    func test_EmailAddressesMatch_ReturnsFalseWhenExpected() {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )
        
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.co"

        XCTAssertFalse(sut.emailAddressesMatch)
    }

    func test_EmailAddressesMatch_ReturnsTrueWhenExpected() {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )

        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        XCTAssertTrue(sut.emailAddressesMatch)
    }

    func test_PasswordsMatch_ReturnsFalseWhenExpected() {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )

        sut.password = "abc123"
        sut.confirmedPassword = "abc12"

        XCTAssertFalse(sut.passwordsMatch)
    }

    func test_PasswordsMatch_ReturnsTrueWhenExpected() {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )

        sut.password = "abc123"
        sut.confirmedPassword = "abc123"

        XCTAssertTrue(sut.passwordsMatch)
    }

    func test_FormIsValid_ReturnsFalseWhenPasswordsDoNotMatch() {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )

        sut.password = "abc123"
        sut.confirmedPassword = "abc12"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        let formIsValid = sut.formIsValid()

        XCTAssertFalse(formIsValid)
        XCTAssertEqual(sut.viewState, .error(CustomError.passwordsDoNotMatchOnSignUp.localizedDescription))
    }

    func test_FormIsValid_ReturnsFalseWhenEmailAddressesDoNotMatch() {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )

        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.co"

        let formIsValid = sut.formIsValid()

        XCTAssertFalse(formIsValid)
        XCTAssertEqual(sut.viewState, .error(CustomError.emailAddressesDoNotMatchOnSignUp.localizedDescription))
    }

    func test_FormIsValid_ReturnsTrueWhenExpected() {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )

        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        XCTAssertTrue(sut.formIsValid())
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnSuccessfullyCreateAccount_ViewStateIsUpdated() async {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: nil)
        )
        fillInMatchingEmailAndPasswordFields()

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .accountCreatedSuccessfully)
    }

    func test_OnUnsuccessfullyCreatingAccount_ErrorIsThrown() async {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(),
            authService: MockAuthService(errorToThrow: FBAuthError.emailAlreadyInUseOnSignUp)
        )
        fillInMatchingEmailAndPasswordFields()

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(FBAuthError.emailAlreadyInUseOnSignUp.localizedDescription))
    }

    func fillInMatchingEmailAndPasswordFields() {
        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"
    }
}