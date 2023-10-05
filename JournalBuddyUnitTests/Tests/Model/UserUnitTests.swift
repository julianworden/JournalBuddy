//
//  UserUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 10/5/23.
//

@testable import JournalBuddy
import XCTest

final class UserUnitTests: XCTestCase {
    var sut: User!
    
    override func setUp() {
        sut = User.example
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_OnIncrementNumberOfTextEntries_PropertyIsIncremented() {
        sut.incrementNumberOfTextEntries()
        
        XCTAssertEqual(sut.numberOfTextEntries, User.example.numberOfTextEntries + 1)
    }
    
    func test_OnDecrementNumberOfTextEntries_PropertyIsDecremented() {
        sut.decrementNumberOfTextEntries()
        
        XCTAssertEqual(sut.numberOfTextEntries, User.example.numberOfTextEntries - 1)
    }
    
    func test_OnIncrementNumberOfVideoEntries_PropertyIsIncremented() {
        sut.incrementNumberOfVideoEntries()
        
        XCTAssertEqual(sut.numberOfVideoEntries, User.example.numberOfVideoEntries + 1)
    }
    
    func test_OnDecrementNumberOfVideoEntries_PropertyIsDecremented() {
        sut.decrementNumberOfVideoEntries()
        
        XCTAssertEqual(sut.numberOfVideoEntries, User.example.numberOfVideoEntries - 1)
    }
    
    func test_OnIncrementNumberOfVoiceEntries_PropertyIsIncremented() {
        sut.incrementNumberOfVoiceEntries()
        
        XCTAssertEqual(sut.numberOfVoiceEntries, User.example.numberOfVoiceEntries + 1)
    }
    
    func test_OnDecrementNumberOfVoiceEntries_PropertyIsDecremented() {
        sut.decrementNumberOfVoiceEntries()
        
        XCTAssertEqual(sut.numberOfVoiceEntries, User.example.numberOfVoiceEntries - 1)
    }
    
    func test_OnIncrementNumberOfCompleteGoals_PropertyIsIncremented() {
        sut.incrementNumberOfCompleteGoals()
        
        XCTAssertEqual(sut.numberOfCompleteGoals, User.example.numberOfCompleteGoals + 1)
    }
    
    func test_OnDecrementNumberOfCompleteGoals_PropertyIsDecremented() {
        sut.decrementNumberOfCompleteGoals()
        
        XCTAssertEqual(sut.numberOfCompleteGoals, User.example.numberOfCompleteGoals - 1)
    }
}
