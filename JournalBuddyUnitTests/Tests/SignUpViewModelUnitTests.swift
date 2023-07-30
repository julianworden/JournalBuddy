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

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertTrue(sut.emailAddress.isEmpty)
        XCTAssertTrue(sut.confirmedEmailAddress.isEmpty)
        XCTAssertTrue(sut.password.isEmpty)
        XCTAssertTrue(sut.confirmedPassword.isEmpty)
    }

    func test_EmailAddressesMatch_ReturnsFalseWhenExpected() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.co"

        XCTAssertFalse(sut.emailAddressesMatch)
    }

    func test_EmailAddressesMatch_ReturnsTrueWhenExpected() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        XCTAssertTrue(sut.emailAddressesMatch)
    }

    func test_PasswordsMatch_ReturnsFalseWhenExpected() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.password = "abc123"
        sut.confirmedPassword = "abc12"

        XCTAssertFalse(sut.passwordsMatch)
    }

    func test_PasswordsMatch_ReturnsTrueWhenExpected() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.password = "abc123"
        sut.confirmedPassword = "abc123"

        XCTAssertTrue(sut.passwordsMatch)
    }

    func test_FormIsValid_ReturnsFalseWhenPasswordsDoNotMatch() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.password = "abc123"
        sut.confirmedPassword = "abc12"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        let formIsValid = sut.formIsValid()

        XCTAssertFalse(formIsValid)
        XCTAssertEqual(sut.viewState, .error(FormError.passwordsDoNotMatchOnSignUp.localizedDescription))
    }

    func test_FormIsValid_ReturnsFalseWhenEmailAddressesDoNotMatch() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.co"

        let formIsValid = sut.formIsValid()

        XCTAssertFalse(formIsValid)
        XCTAssertEqual(sut.viewState, .error(FormError.emailAddressesDoNotMatchOnSignUp.localizedDescription))
    }

    func test_FormIsValid_ReturnsTrueWhenExpected() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"

        XCTAssertTrue(sut.formIsValid())
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnSuccessfulSignUpButtonTapped_ViewStateIsUpdated() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        fillInMatchingEmailAndPasswordFields()

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .accountCreatedSuccessfully)
    }

    func test_OnUnsuccessfullSignUpButtonTapped_ErrorIsThrown() async {
        initializeSUT(databaseServiceError: nil, authServiceError: TestError.general)
        fillInMatchingEmailAndPasswordFields()

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func test_OnSignUpButtonTappedWithInvalidForm_ErrorIsThrown() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.co"

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(FormError.emailAddressesDoNotMatchOnSignUp.localizedDescription))
    }

    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = SignUpViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError)
        )
    }

    func fillInMatchingEmailAndPasswordFields() {
        sut.password = "abc123"
        sut.confirmedPassword = "abc123"
        sut.emailAddress = "julianworden@gmail.com"
        sut.confirmedEmailAddress = "julianworden@gmail.com"
    }
}
