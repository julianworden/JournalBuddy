//
//  LoginViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/27/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class LoginViewModelUnitTests: XCTestCase {
    var sut: LoginViewModel!

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertTrue(sut.emailAddress.isEmpty)
        XCTAssertTrue(sut.password.isEmpty)
    }

    func test_OnSuccessfulLogIn_ViewStateIsUpdated() async {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        await sut.logIn()

        XCTAssertEqual(sut.viewState, .loggedIn(User.example))
    }

    func test_OnUnsuccessfulLogIn_ViewStateIsUpdated() async {
        initializeSUT(databaseServiceError: nil, authServiceError: TestError.general)

        await sut.logIn()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = LoginViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError)
        )
    }
}
