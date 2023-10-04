//
//  FBConstantsUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 10/4/23.
//

@testable import JournalBuddy
import XCTest

final class FBConstantsUnitTests: XCTestCase {
    func test_TextEntryBatchSize_IsCorrect() {
        XCTAssertEqual(FBConstants.textEntryBatchSize, 12)
    }
    
    func test_VoiceEntryBatchSize_IsCorrect() {
        XCTAssertEqual(FBConstants.voiceEntryBatchSize, 16)
    }
}
