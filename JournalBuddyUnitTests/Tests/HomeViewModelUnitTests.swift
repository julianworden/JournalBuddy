//
//  HomeViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/27/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class HomeViewModelUnitTests: XCTestCase {
    var sut: HomeViewModel!

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnSuccessfulLogOut_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: nil)

        sut.logOut()

        XCTAssertEqual(sut.viewState, .userLoggedOut)
    }

    func test_OnUnsuccessfulLogOut_ViewStateIsUpdated() {
        initializeSUT(databaseServiceError: nil, authServiceError: TestError.general)

        sut.logOut()

        XCTAssertEqual(sut.viewState, .error(TestError.general.localizedDescription))
    }

    func initializeSUT(databaseServiceError: Error?, authServiceError: Error?) {
        sut = HomeViewModel(
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError)
        )
    }
}
