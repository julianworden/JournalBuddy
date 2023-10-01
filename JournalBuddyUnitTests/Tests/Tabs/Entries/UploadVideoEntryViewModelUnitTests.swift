//
//  UploadVideoEntryViewModelUnitTests.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 8/25/23.
//

import AVFoundation
import Combine
@testable import JournalBuddy
import Photos
import XCTest

@MainActor
final class UploadVideoEntryViewModelUnitTests: XCTestCase {
    var sut: UploadVideoEntryViewModel!
    var cancellables = Set<AnyCancellable>()
    
    var videoEntryIsSavingExpectation: XCTestExpectation!
    var videoEntryWasSavedExpectation: XCTestExpectation!
    var videoEntryIsUploadingExpectation: XCTestExpectation!
    var videoEntryWasUploadedExpectation: XCTestExpectation!
    var videoEntryWasCreatedNotificationExpectation: XCTNSNotificationExpectation!
    
    override func setUp() {
        videoEntryIsSavingExpectation = XCTestExpectation(
            description: "viewState updated to .videoEntryIsSavingToDevice."
        )
        videoEntryWasSavedExpectation = XCTestExpectation(
            description: "viewState updated to .videoEntryWasSavedToDevice."
        )
        videoEntryIsUploadingExpectation = XCTestExpectation(
            description: "viewState updated to .videoEntryIsUploading."
        )
        videoEntryWasUploadedExpectation = XCTestExpectation(
            description: "viewState updated to .videoEntryWasUploaded."
        )
        videoEntryWasCreatedNotificationExpectation = XCTNSNotificationExpectation(
            name: .videoEntryWasCreated
        )
    }

    override func tearDown() {
        sut = nil
        cancellables = Set<AnyCancellable>()
        videoEntryIsSavingExpectation = nil
        videoEntryWasSavedExpectation = nil
        videoEntryIsUploadingExpectation = nil
        videoEntryWasUploadedExpectation = nil
        videoEntryWasCreatedNotificationExpectation = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
        
        XCTAssertEqual(sut.viewState, .displayingView)
        XCTAssertEqual(sut.recordedVideoURL, Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!)
        XCTAssertFalse(sut.saveVideoToDevice)
        XCTAssertTrue(sut.videoWasSelectedFromLibrary)
    }
    
    // Consider adding commented code into a new VideoPlayerViewModel in the future
    
//    func test_VideoPlayerCurrentItemLengthInSeconds_ReturnsExpectedValue() {
//        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
//        let expectation = XCTestExpectation(description: "The video's length was retrieved")
//        
//        waitForVideoPlayerReadyToPlayStatus {
//            if self.sut.videoPlayerCurrentItemLengthInSeconds == 2 {
//                expectation.fulfill()
//            }
//        }
//        
//        wait(for: [expectation], timeout: 3)
//    }
    
//    func test_OnVideoPlayerPlayButtonTapped_VideoPlayerStartsPlaying() {
//        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
//        let expectation = XCTestExpectation(description: "Video player is playing.")
//        sut.player
//            .publisher(for: \.timeControlStatus)
//            .sink { timeControlStatus in
//                if timeControlStatus == .playing {
//                    expectation.fulfill()
//                }
//            }
//            .store(in: &cancellables)
//        
//        waitForVideoPlayerReadyToPlayStatus {
//            self.sut.videoPlayerPlayButtonTapped()
//        }
//                
//        wait(for: [expectation], timeout: 3)
//    }
//    
//    func test_OnVideoPlayerPauseButtonTapped_VideoPlayerPauses() {
//        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
//        let expectation = XCTestExpectation(description: "Video player is paused.")
//        
//        waitForVideoPlayerReadyToPlayStatus {
//            self.sut.videoPlayer.play()
//            self.sut.videoPlayerPauseButtonTapped()
//            XCTAssertEqual(self.sut.videoPlayer.timeControlStatus, .paused)
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 3)
//    }
//    
//    func test_OnVideoPlayerRestartButtonTapped_VideoPlayerRestartsAndPlays() {
//        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
//        let expectation = XCTestExpectation(description: "Video player restarted and played successfully.")
//        
//        waitForVideoPlayerReadyToPlayStatus {
//            self.sut.videoPlayer.play()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                self.sut.videoPlayerRestartButtonTapped()
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    XCTAssertEqual(
//                        self.sut.videoPlayer.currentTime().seconds,
//                        3,
//                        accuracy: 0.5,
//                        "The video player should start over from the very beginning."
//                    )
//                    XCTAssertEqual(
//                        self.sut.videoPlayer.timeControlStatus,
//                        .playing,
//                        "After restarting the video player should automatically start playing again."
//                    )
//                    expectation.fulfill()
//                }
//            }
//        }
//        
//        wait(for: [expectation], timeout: 10)
//    }
//    
//    func test_OnSeekVideoPlayer_VideoPlayerSeeks() {
//        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
//        let expectation = XCTestExpectation(description: "Video player did seek 5 seconds into the video.")
//        
//        waitForVideoPlayerReadyToPlayStatus {
//            Task {
//                await self.sut.seekVideoPlayer(to: 5)
//    
//                XCTAssertEqual(self.sut.videoPlayer.currentTime().seconds, 5)
//                expectation.fulfill()
//            }
//        }
//        
//        wait(for: [expectation], timeout: 3)
//    }
    
    func test_OnUploadButtonTappedWithSaveToDeviceEnabled_SavingAndUploadingCompleteSuccessfully() async {
        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
        sut.saveVideoToDevice = true

        subscribeToViewStateUpdates()
        
        await sut.uploadButtonTapped(photoLibrary: MockPHPhotoLibrary(errorToThrow: nil))
        
        await fulfillment(
            of: [
                videoEntryIsSavingExpectation,
                videoEntryWasSavedExpectation,
                videoEntryIsUploadingExpectation,
                videoEntryWasUploadedExpectation,
                videoEntryWasCreatedNotificationExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnUploadButtonTappedWithSaveToDeviceEnabled_VideoDoesNotStartUploadingWhenSavingErrorIsThrown() async throws {
        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
        sut.saveVideoToDevice = true
        
        subscribeToViewStateUpdates()
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .videoEntryIsUploading, .videoEntryWasUploaded:
                    XCTFail("An error should have been thrown during saving and uploading shouldn't have started.")
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        await sut.uploadButtonTapped(photoLibrary: MockPHPhotoLibrary(errorToThrow: TestError.general))
        
        // Give the view model the chance to set uploading-related view states. Test will fail if this happens
        try await Task.sleep(seconds: 3)
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func test_OnUploadButtonTappedWithSaveToDeviceDisabled_SavingToDeviceDoesNotOccurAndUploadingIsSuccessful() async {
        initializeSUTWith(databaseServiceError: nil, authServiceError: nil)
        
        subscribeToViewStateUpdates()
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .videoEntryIsSavingToDevice, .videoEntryWasSavedToDevice:
                    XCTFail("The video entry shouldn't be getting saved to the device.")
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        await sut.uploadButtonTapped(photoLibrary: MockPHPhotoLibrary(errorToThrow: nil))
        
        await fulfillment(
            of: [
                videoEntryIsUploadingExpectation,
                videoEntryWasUploadedExpectation,
                videoEntryWasCreatedNotificationExpectation
            ],
            timeout: 3,
            enforceOrder: true
        )
    }
    
    func test_OnUploadButtonTapped_ErrorViewStateIsSetWhenUploadingFails() async {
        initializeSUTWith(databaseServiceError: TestError.general, authServiceError: nil)
        
        await sut.uploadButtonTapped()
        
        XCTAssertEqual(sut.viewState, .error(message: TestError.general.localizedDescription))
    }
    
    func initializeSUTWith(databaseServiceError: Error?, authServiceError: Error?) {
        sut = UploadVideoEntryViewModel(
            isTesting: true,
            recordedVideoURL: Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!,
            videoWasSelectedFromLibrary: true,
            databaseService: MockDatabaseService(errorToThrow: databaseServiceError),
            authService: MockAuthService(errorToThrow: authServiceError)
        )
    }
    
    func subscribeToViewStateUpdates() {
        sut.$viewState
            .sink { viewState in
                switch viewState {
                case .videoEntryIsSavingToDevice:
                    self.videoEntryIsSavingExpectation.fulfill()
                case .videoEntryWasSavedToDevice:
                    self.videoEntryWasSavedExpectation.fulfill()
                case .videoEntryIsUploading:
                    self.videoEntryIsUploadingExpectation.fulfill()
                case .videoEntryWasUploaded:
                    self.videoEntryWasUploadedExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
//    func waitForVideoPlayerReadyToPlayStatus(completion: @escaping () -> Void) {
//        sut.videoPlayer
//            .publisher(for: \.currentItem?.status)
//            .sink { status in
//                if status == .readyToPlay {
//                    completion()
//                }
//            }
//            .store(in: &cancellables)
//    }
}


