//
//  Notification.Name+Helpers.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/6/23.
//

import Foundation

extension Notification.Name {
    /// Used to notify `EntriesViewController` that a new text entry was created. Use the
    /// `NotificationConstants.createdTextEntry userInfo` key to access the text entry that was created.
    static let textEntryWasCreated = Notification.Name("textEntryWasCreated")
    
    /// Used to notify `EntriesViewController` that a text entry was updated. Use the
    /// `NotificationConstants.updatedTextEntry userInfo` key to access the text entry that was updated.
    static let textEntryWasUpdated = Notification.Name("textEntryWasUpdated")
    
    /// Used to notify `EntriesViewController` that a text entry was deleted. Use the
    /// `NotificationConstants.deletedTextEntry userInfo` key to access the text entry that was deleted.
    static let textEntryWasDeleted = Notification.Name("textEntryWasDeleted")
    
    /// Used to notify `UploadVideoViewController` that a video entry is currently uploading, posted every time uploading progress is made.
    /// Use the `NotificationConstants.uploadingProgress userInfo` key to access the uploading progress. This
    /// will be a value between 0 and 1, where 0 is no uploading progress and 1 signifies a completed upload.
    static let videoIsUploading = Notification.Name("videoIsUploading")
    
    /// Used to notify `EntriesViewController` that a new video entry was created. Use the
    /// `NotificationConstants.createdVideoEntry userInfo` key to access the video entry that was created.
    static let videoEntryWasCreated = Notification.Name("videoEntryWasCreated")
    
    /// Used to notify `CreateVoiceEntryViewController` that a voice entry is currently uploading, posted every time uploading progress is made.
    /// Use the `NotificationConstants.uploadingProgress userInfo` key to access the uploading progress. This
    /// will be a value between 0 and 1, where 0 is no uploading progress and 1 signifies a completed upload.
    static let voiceEntryIsUploading = Notification.Name("voiceEntryIsUploading")
    
    /// Used to notify `EntriesViewController` that a video entry was deleted. Use the
    /// `NotificationConstants.deletedVideoEntry userInfo` key to access the video entry that was deleted.
    static let videoEntryWasDeleted = Notification.Name("videoEntryWasDeleted")
    
    /// Used to notify `EntriesViewController` that a new voice entry was created. Use the
    /// `NotificationConstants.createdVoiceEntry userInfo` key to access the voice entry that was created.
    static let voiceEntryWasCreated = Notification.Name("voiceEntryWasCreated")
    
    /// Used to notify `EntriesViewController` that a voice entry was deleted. Use the
    /// `NotificationConstants.deletedVoiceEntry userInfo` key to access the video entry that was deleted.
    static let voiceEntryWasDeleted = Notification.Name("voiceEntryWasDeleted")
    
    /// Posted when a new goal is saved or when an existing goal is updated. Access the `NotificationConstants.savedGoal userInfo`
    /// key to access the newly saved goal.
    static let goalWasSaved = Notification.Name("goalWasSaved")
    
    /// Posted when a goal is deleted. Access the `NotificationConstants.deletedGoal userInfo`
    /// key to access the deleted goal.
    static let goalWasDeleted = Notification.Name("goalWasDeleted")
}
