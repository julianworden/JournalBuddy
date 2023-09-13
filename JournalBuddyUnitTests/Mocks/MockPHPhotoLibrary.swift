//
//  MockPHPhotoLibrary.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 9/11/23.
//

import Foundation
@testable import JournalBuddy
import Photos

class MockPHPhotoLibrary: PHPhotoLibraryProtocol {
    var errorToThrow: Error?
    
    init(errorToThrow: Error?) {
        self.errorToThrow = errorToThrow
    }
    
    func performChanges(_ changeBlock: @escaping () -> Void) async throws {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return
        }
    }
}
