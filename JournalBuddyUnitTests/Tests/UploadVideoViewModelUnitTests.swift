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
    var sut: UploadVideoEntryViewModel!

    override func tearDown() {
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
        
        XCTAssertFalse(sut.videoPlayerCurrentItemIsFinished)
        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertEqual(sut.recordedVideoURL, URL(string: "https://example.com")!)
        XCTAssertNil(sut.videoPlayerPeriodicTimeObserver)
    }
    
    func test_OnSuccessfullySaveVideoEntry_ViewStateIsUpdated() async {
        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
        
        await sut.uploadButtonTapped()
        
        XCTAssertEqual(sut.viewState, .videoEntryWasCreated)
    }
    
    func test_OnUnSuccessfullySaveVideoEntry_ViewStateIsUpdated() async {
        initializeSUTWith(databaseServiceError: TestError.general, authServiceError: nil)
        
        await sut.uploadButtonTapped()
        
        XCTAssertEqual(sut.viewState, .error(message: VideoEntryError.uploadFailed.localizedDescription))
    }
    
    func initializeSUTWith(databaseServiceError: Error?, authServiceError: Error?) {
        sut = UploadVideoEntryViewModel(
            recordedVideoURL: URL(string: "https://example.com")!,
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError)
        )
    }
}
