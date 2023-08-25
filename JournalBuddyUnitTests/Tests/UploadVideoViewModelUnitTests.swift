//
//  UploadVideoViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 8/25/23.
//

@testable import JournalBuddy
import XCTest

@MainActor
final class UploadVideoViewModelUnitTests: XCTestCase {
    var sut: UploadVideoViewModel!

    override func setUp() {
        sut = UploadVideoViewModel(recordedVideoURL: URL(string: "https://example.com")!)
    }

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertFalse(sut.videoPlayerCurrentItemIsFinished)
        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertEqual(sut.recordedVideoURL, URL(string: "https://example.com")!)
    }
}
