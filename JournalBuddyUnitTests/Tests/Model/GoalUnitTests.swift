//
//  GoalUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 10/7/23.
//

@testable import JournalBuddy
import XCTest

final class GoalUnitTests: XCTestCase {
    var sut: Goal!
    
    override func setUp() {
        sut = Goal.example
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_OnComplete_PropertiesAreUpdated() {
        sut.complete()
        
        XCTAssertTrue(sut.isComplete)
        XCTAssertNotNil(sut.unixDateCompleted)
    }
}
