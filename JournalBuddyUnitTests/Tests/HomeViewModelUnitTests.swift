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
        sut = HomeViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnSuccessfulLogOut_ViewStateIsUpdated() {
        sut = HomeViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: nil)
        )

        sut.logOut()

        XCTAssertEqual(sut.viewState, .userLoggedOut)
    }

    func test_OnUnsuccessfulLogOut_ViewStateIsUpdated() {
        sut = HomeViewModel(
            databaseService: MockDatabaseService(errorToThrow: nil),
            authService: MockAuthService(errorToThrow: TestError.general)
        )

        sut.logOut()

        XCTAssertEqual(sut.viewState, .error(CustomError.unknown(TestError.general.localizedDescription).localizedDescription))
    }
}
