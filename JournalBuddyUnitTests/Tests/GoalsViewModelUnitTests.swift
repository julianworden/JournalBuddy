//
//  GoalsViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 8/13/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class GoalsViewModelUnitTests: XCTestCase {
    var sut: GoalsViewModel!

    override func setUp() {
        sut = GoalsViewModel()
    }

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertEqual(sut.viewState, .fetchingGoals)
    }
}
