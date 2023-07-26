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

    override func setUp() {
        sut = SignUpViewModel(databaseService: MockDatabaseService(), authService: MockAuthService())
    }

    override func tearDown() {
        sut = nil
    }

    func test_EmailAddressesMatch_ReturnsFalseWhenExpected() {
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.co"

        XCTAssertFalse(sut.emailAddressesMatch)
    }

    func test_EmailAddressesMatch_ReturnsTrueWhenExpected() {
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        XCTAssertTrue(sut.emailAddressesMatch)
    }

    func test_PasswordsMatch_ReturnsFalseWhenExpected() {
        sut.password = "abc123"
        sut.confirmedPassword = "abc12"

        XCTAssertFalse(sut.passwordsMatch)
    }

    func test_PasswordsMatch_ReturnsTrueWhenExpected() {
        sut.password = "abc123"
        sut.confirmedPassword = "abc123"

        XCTAssertTrue(sut.passwordsMatch)
    }

    func test_FormIsValid_ReturnsFalseWhenPasswordsDoNotMatch() {
        sut.password = "abc123"
        sut.confirmedPassword = "abc12"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        let formIsValid = sut.formIsValid()

        XCTAssertFalse(formIsValid)
        XCTAssertEqual(sut.viewState, .error(CustomError.passwordsDoNotMatchOnSignUp.localizedDescription))
    }

    func test_FormIsValid_ReturnsFalseWhenEmailAddressesDoNotMatch() {
        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.co"

        let formIsValid = sut.formIsValid()

        XCTAssertFalse(formIsValid)
        XCTAssertEqual(sut.viewState, .error(CustomError.emailAddressesDoNotMatchOnSignUp.localizedDescription))
    }

    func test_FormIsValid_ReturnsTrueWhenExpected() {
        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        XCTAssertTrue(sut.formIsValid())
        XCTAssertEqual(sut.viewState, .displayingView)
    }
}
