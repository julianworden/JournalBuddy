//
//  PHPhotoLibraryProtocol.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 9/11/23.
//

import Foundation
import Photos

protocol PHPhotoLibraryProtocol {    
    func performChanges(_ changeBlock: @escaping () -> Void) async throws
}

extension PHPhotoLibrary: PHPhotoLibraryProtocol { }
