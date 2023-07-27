//
//  LoginViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/27/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class LoginViewModelUnitTests: XCTestCase, MainTestCase {
    var sut: LoginViewModel!

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = LoginViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertTrue(sut.emailAddress.isEmpty)
        XCTAssertTrue(sut.password.isEmpty)
    }

    func test_OnSuccessfulLogIn_ViewStateIsUpdated() async {
        sut = LoginViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        await sut.logIn()

        XCTAssertEqual(sut.viewState, .loggedIn)
    }

    func test_OnUnsuccessfulLogIn_ViewStateIsUpdated() async {
        sut = LoginViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: TestError.general)
        )

        await sut.logIn()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }
}
