//
//  CreateVideoEntryViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 8/25/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class CreateVideoEntryViewModelUnitTests: XCTestCase {
    var sut: CreateVideoEntryViewModel!

    override func setUp() {
        sut = CreateVideoEntryViewModel()
    }

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertEqual(sut.viewState, .displayingView)
    }
}
