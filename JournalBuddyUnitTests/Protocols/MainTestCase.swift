//
//  MainTestCase.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/27/23.
//

/// Ensures that all conforming `XCTestCase`s perform a standard set of tests.
protocol MainTestCase {
    @MainActor func test_OnInit_DefaultValuesAreCorrect()
}
