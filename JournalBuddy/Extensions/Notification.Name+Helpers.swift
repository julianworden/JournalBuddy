//
//  Notification.Name+Helpers.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/6/23.
//

import Foundation

extension Notification.Name {
    /// Used to notify `UploadVideoViewController` that a video entry is currently uploading, posted every time uploading progress is made.
    /// Use the `NotificationConstants.uploadingProgress userInfo` key to access the uploading progress. This
    /// will be a value between 0 and 1, where 0 is no uploading progress and 1 signifies a completed upload.
    static let videoIsUploading = Notification.Name("videoIsUploading")
    /// Used to notify `CreateVoiceEntryViewController` that a voice entry is currently uploading, posted every time uploading progress is made.
    /// Use the `NotificationConstants.uploadingProgress userInfo` key to access the uploading progress. This
    /// will be a value between 0 and 1, where 0 is no uploading progress and 1 signifies a completed upload.
    static let voiceEntryIsUploading = Notification.Name("voiceEntryIsUploading")
    /// Posted when a new goal is saved or when an existing goal is updated. Access the `NotificationConstants.savedGoal userInfo`
    /// key to access the newly saved goal.
    static let goalWasSaved = Notification.Name("goalWasSaved")
}
