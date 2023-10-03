//
//  DatabaseService.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import AVFoundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

final class DatabaseService: DatabaseServiceProtocol {
    private let db = Firestore.firestore()
    private lazy var usersCollection = db.collection(FBConstants.users)
    
    private let storage = Storage.storage()
    private lazy var storageRef = storage.reference()

    let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - User

    func getUser(withUID uid: String) async throws -> User {
        do {
            return try await usersCollection
                .document(uid)
                .getDocument(as: User.self)
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }

    func createUser(_ user: User) async throws {
        do {
            try await usersCollection
                .document(user.uid)
                .setData(
                    [
                        FBConstants.uid: user.uid,
                        FBConstants.emailAddress: user.emailAddress
                    ]
                )
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }

    // MARK: - Generic Entry CRUD

    func fetchFirstEntriesBatch<T: Entry>(_ entryType: EntryType, forUID uid: String) async throws -> [T] {
        do {
            switch entryType {
            case .text:
                return try await fetchFirstTwelveTextEntries(forUID: uid) as! [T]
            case .video:
                return try await fetchVideoEntries(forUID: uid) as! [T]
            case .voice:
                return try await fetchVoiceEntries(forUID: uid) as! [T]
            }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }
    
    func fetchNextEntriesBatch<T: Entry>(after oldestFetchedEntry: T, forUID uid: String) async throws -> [T] {
        do {
            switch oldestFetchedEntry.type {
            case .text:
                let oldestFetchedTextEntry = oldestFetchedEntry as! TextEntry
                return try await fetchNextTenTextEntries(
                    before: oldestFetchedTextEntry,
                    forUID: uid
                ) as! [T]
            case .video:
                return try await fetchVideoEntries(forUID: uid) as! [T]
            case .voice:
                return try await fetchVoiceEntries(forUID: uid) as! [T]
            }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }
    
    /// Analyzes a given `Entry` to determine how it should be saved based on its `type`. Once this determination is made, a subsequent call to the appropriate
    /// `DatabaseService` method is made to save the `entry` to Firestore.
    /// - Parameters:
    ///   - entry: The entry that is to be saved.
    ///   - url: The local URL on the user's device where the `entry` is being stored. This will only be non-nil when a `VideoEntry` or `VoiceEntry`
    ///   is being saved.
    /// - Returns: The `Entry` that was saved.
    @discardableResult func saveEntry<T: Entry>(_ entry: T, at url: URL?) async throws -> T {
        do {
            switch entry.type {
            case .text:
                let textEntry = entry as! TextEntry
                return try await saveTextEntry(textEntry) as! T
            case .video:
                let videoEntry = entry as! VideoEntry
                return try await saveVideoEntry(videoEntry, at: url!) as! T
            case .voice:
                let voiceEntry = entry as! VoiceEntry
                return try await saveVoiceEntry(voiceEntry, at: url!) as! T
            }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }

    func updateEntry<T: Entry>(_ entry: T) async throws {
        do {
            switch entry.type {
            case .text:
                let textEntry = entry as! TextEntry
                try await updateTextEntry(textEntry)
            default:
                fatalError("No other types of entries have been implemented yet.")
            }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.updateDataFailed(systemError: error.localizedDescription)
        }
    }

    func deleteEntry<T: Entry>(_ entry: T) async throws {
        do {
            switch entry.type {
            case .text:
                try await usersCollection
                    .document(entry.creatorUID)
                    .collection(FBConstants.textEntries)
                    .document(entry.id)
                    .delete()
            case .video:
                try await usersCollection
                    .document(entry.creatorUID)
                    .collection(FBConstants.videoEntries)
                    .document(entry.id)
                    .delete()
                try await deleteVideoEntryFromFBStorage(entry as! VideoEntry)
            case .voice:
                try await usersCollection
                    .document(entry.creatorUID)
                    .collection(FBConstants.voiceEntries)
                    .document(entry.id)
                    .delete()
                try await deleteVoiceEntryFromFBStorage(entry as! VoiceEntry)
            }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.deleteDataFailed(systemError: error.localizedDescription)
        }
    }

    // MARK: - TextEntry

    private func fetchFirstTwelveTextEntries(forUID uid: String) async throws -> [TextEntry] {
        do {
            let query = try await usersCollection
                .document(uid)
                .collection(FBConstants.textEntries)
                .order(by: FBConstants.unixDate, descending: true)
                .limit(to: 12)
                .getDocuments()

            return try query.documents.map { try $0.data(as: TextEntry.self) }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }
    
    private func fetchNextTenTextEntries(
        before oldestFetchedEntry: TextEntry,
        forUID uid: String
    ) async throws -> [TextEntry] {
        do {
            let query = try await usersCollection
                .document(uid)
                .collection(FBConstants.textEntries)
                .order(by: FBConstants.unixDate, descending: true)
                .whereField(FBConstants.unixDate, isLessThan: oldestFetchedEntry.unixDate)
                .limit(to: 12)
                .getDocuments()

            return try query.documents.map { try $0.data(as: TextEntry.self) }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }

    private func saveTextEntry(_ textEntry: TextEntry) async throws -> TextEntry {
        do {
            let newDocument = try usersCollection
                .document(textEntry.creatorUID)
                .collection(FBConstants.textEntries)
                .addDocument(from: textEntry)

            try await newDocument.updateData([FBConstants.id: newDocument.documentID])
            var textEntryWithID = textEntry
            textEntryWithID.id = newDocument.documentID
            return textEntryWithID
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }

    private func updateTextEntry(_ textEntry: TextEntry) async throws {
        do {
            try await usersCollection
                .document(textEntry.creatorUID)
                .collection(FBConstants.textEntries)
                .document(textEntry.id)
                .updateData([FBConstants.text: textEntry.text])
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.updateDataFailed(systemError: error.localizedDescription)
        }
    }
    
    // MARK: - VideoEntry
    
    func fetchVideoEntries(forUID uid: String) async throws -> [VideoEntry] {
        do {
            let query = try await usersCollection
                .document(uid)
                .collection(FBConstants.videoEntries)
                .getDocuments()

            return try query.documents.map { try $0.data(as: VideoEntry.self) }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }
    
    /// Uploads a given video entry to Firestore and then saves that video entry's info in Firestore.
    /// - Parameters:
    ///   - videoEntry: The video entry that is to be saved to Firestore. This argument is not expected to have a valid `downloadURL`
    ///   or `id` property, as those properties will be assigned during this method's execution.
    ///   - url: The local URL on the user's device where the video entry that is to be saved is being stored.
    /// - Returns: The saved video entry, which should have valid `downloadURL` and `id` properties, as they were assigned during
    /// the execution of the method.
    private func saveVideoEntry(_ videoEntry: VideoEntry, at url: URL) async throws -> VideoEntry {
        let videoEntryDownloadURL = try await uploadVideoEntryToFBStorage(upload: videoEntry, at: url)
        let videoEntryThumbnailDownloadURL = try await uploadVideoEntryThumbnailToFBStorage(videoEntry: videoEntry, videoEntryLocalURL: url)
        var newVideoEntry = videoEntry
        newVideoEntry.downloadURL = videoEntryDownloadURL.absoluteString
        newVideoEntry.thumbnailDownloadURL = videoEntryThumbnailDownloadURL.absoluteString
        
        do {
            let newVideoEntryDocumentReference = try usersCollection
                .document(newVideoEntry.creatorUID)
                .collection(FBConstants.videoEntries)
                .addDocument(from: newVideoEntry)
            try await newVideoEntryDocumentReference
                .updateData([FBConstants.id: newVideoEntryDocumentReference.documentID])
            newVideoEntry.id = newVideoEntryDocumentReference.documentID
            
            return newVideoEntry
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }
    
    // MARK: - VoiceEntry
    
    func fetchVoiceEntries(forUID uid: String) async throws -> [VoiceEntry] {
        do {
            let query = try await usersCollection
                .document(uid)
                .collection(FBConstants.voiceEntries)
                .getDocuments()

            return try query.documents.map { try $0.data(as: VoiceEntry.self) }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }
    
    private func saveVoiceEntry(_ voiceEntry: VoiceEntry, at url: URL) async throws -> VoiceEntry {
        let voiceEntryDownloadURL = try await uploadVoiceEntryToFBStorage(upload: voiceEntry, at: url)
        var newVoiceEntry = voiceEntry
        newVoiceEntry.downloadURL = voiceEntryDownloadURL.absoluteString
        
        do {
            let newVoiceEntryDocumentReference = try usersCollection
                .document(newVoiceEntry.creatorUID)
                .collection(FBConstants.voiceEntries)
                .addDocument(from: newVoiceEntry)
            try await newVoiceEntryDocumentReference
                .updateData([FBConstants.id: newVoiceEntryDocumentReference.documentID])
            
            newVoiceEntry.id = newVoiceEntryDocumentReference.documentID
            
            return newVoiceEntry
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }
    
    // MARK: - Goal
    
    func fetchGoals() async throws -> [Goal] {
        do {
            let snapshot = try await usersCollection
                .document(authService.currentUserUID)
                .collection(FBConstants.goals)
                .getDocuments()
            
            return try snapshot
                .documents
                .map { try $0.data(as: Goal.self) }
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.fetchDataFailed(systemError: error.localizedDescription)
        }
    }
    
    @discardableResult func saveNewGoal(_ newGoal: Goal) async throws -> Goal {
        do {
            let newGoalRef = try usersCollection
                .document(newGoal.creatorUID)
                .collection(FBConstants.goals)
                .addDocument(from: newGoal)
            
            try await newGoalRef.updateData(
                [FBConstants.id: newGoalRef.documentID]
            )
            
            var newGoalWithID = newGoal
            newGoalWithID.id = newGoalRef.documentID
            return newGoalWithID
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }
    
    func completeGoal(_ completedGoal: Goal) async throws {
        do {
            try await usersCollection
                .document(completedGoal.creatorUID)
                .collection(FBConstants.goals)
                .document(completedGoal.id)
                .updateData([FBConstants.isComplete: true])
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }
    
    func updateGoal(_ updatedGoal: Goal) async throws {
        do {
            try usersCollection
                .document(updatedGoal.creatorUID)
                .collection(FBConstants.goals)
                .document(updatedGoal.id)
                .setData(from: updatedGoal)
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.updateDataFailed(systemError: error.localizedDescription)
        }
    }
    
    func deleteGoal(_ goalToDelete: Goal) async throws {
        do {
            try await usersCollection
                .document(goalToDelete.creatorUID)
                .collection(FBConstants.goals)
                .document(goalToDelete.id)
                .delete()
        } catch {
            print(error.emojiMessage)
            throw FBFirestoreError.deleteDataFailed(systemError: error.localizedDescription)
        }
    }
    
    // MARK: - Firebase Storage
    
    /// Uploads a video entry to Firebase Storage.
    /// - Parameters:
    ///   - videoEntry: The video entry to upload to Firebase Storage.
    ///   - url: The local URL on the user's device where the video entry is being stored.
    /// - Returns: The download URL for `videoEntry` that was provided by Firebase Storage. This method's caller should use this
    /// URL as the `videoEntry`'s `downloadURL` property.
    private func uploadVideoEntryToFBStorage(upload videoEntry: VideoEntry, at url: URL) async throws -> URL {
        do {
            let newVideoEntryLocationRef = storageRef.child(
                "Users/\(videoEntry.creatorUID)/Video Entries/\(videoEntry.unixDate)/\(videoEntry.unixDate).mov"
            )
            
            let videoData = try Data(contentsOf: url)
            
            _ = try await newVideoEntryLocationRef.putDataAsync(videoData) { progress in
                guard let progress else { return }
                
                NotificationCenter.default.post(
                    name: .videoIsUploading,
                    object: nil,
                    userInfo: [NotificationConstants.uploadingProgress: progress.fractionCompleted]
                )
            }
            
            do {
                let downloadURL = try await newVideoEntryLocationRef.downloadURL()
                return downloadURL
            } catch {
                throw VideoEntryError.failedToFetchEntryDownloadURL
            }
        } catch {
            throw FBStorageError.uploadDataFailed(systemError: error.localizedDescription)
        }
    }
    
    private func uploadVideoEntryThumbnailToFBStorage(videoEntry: VideoEntry, videoEntryLocalURL: URL) async throws -> URL {
        do {
            let newVideoEntryThumbnailRef = storageRef.child(
                "Users/\(videoEntry.creatorUID)/Video Entries/\(videoEntry.unixDate)/\(videoEntry.unixDate).jpeg"
            )
            let videoAsset = AVAsset(url: videoEntryLocalURL)
            let videoThumbnailGenerator = AVAssetImageGenerator(asset: videoAsset)
            videoThumbnailGenerator.requestedTimeToleranceBefore = .zero
            videoThumbnailGenerator.requestedTimeToleranceAfter = CMTime(value: 3, timescale: 1)
            // Keeps image in video's orientation and stops it from rotating into landscape
            videoThumbnailGenerator.appliesPreferredTrackTransform = true
            
            let imageAsCGImage = try await videoThumbnailGenerator.image(at: .zero).image
            let imageAsUIImage = UIImage(cgImage: imageAsCGImage)
            
            guard let imageData = imageAsUIImage.jpegData(compressionQuality: 0.7) else {
                throw VideoEntryError.thumbnailGenerationFailed
            }
            
            _ = try await newVideoEntryThumbnailRef.putDataAsync(imageData)
            
            do {
                let thumbnailDownloadURL = try await newVideoEntryThumbnailRef.downloadURL()
                return thumbnailDownloadURL
            } catch {
                print(error.emojiMessage)
                throw VideoEntryError.failedToFetchThumbnailDownloadURL
            }
        } catch {
            print(error.emojiMessage)
            throw VideoEntryError.thumbnailUploadingFailed
        }
    }
    
    private func uploadVoiceEntryToFBStorage(upload voiceEntry: VoiceEntry, at url: URL) async throws -> URL {
        do {
            let newVoiceEntryRef = storageRef.child(
                "Users/\(voiceEntry.creatorUID)/Voice Entries/\(voiceEntry.unixDate).m4a"
            )
            let voiceEntryData = try Data(contentsOf: url)
            
            _ = try await newVoiceEntryRef.putDataAsync(voiceEntryData) { progress in
                guard let progress else { return }
                
                NotificationCenter.default.post(
                    name: .voiceEntryIsUploading,
                    object: nil,
                    userInfo: [NotificationConstants.uploadingProgress: progress.fractionCompleted]
                )
            }
            
            do {
                let voiceEntryDownloadURL = try await newVoiceEntryRef.downloadURL()
                return voiceEntryDownloadURL
            } catch {
                print(error.emojiMessage)
                throw VoiceEntryError.failedToFetchDownloadURL
            }
        } catch {
            print(error.emojiMessage)
            throw VoiceEntryError.uploadingFailed
        }
    }
    
    private func deleteVideoEntryFromFBStorage(_ videoEntry: VideoEntry) async throws {
        do {
            let videoEntryReference = storage.reference(forURL: videoEntry.downloadURL)
            let videoEntryThumbnailReference = storage.reference(forURL: videoEntry.thumbnailDownloadURL)
            
            try await videoEntryReference.delete()
            try await videoEntryThumbnailReference.delete()
        } catch {
            print(error.emojiMessage)
            throw FBStorageError.deleteDataFailed(systemError: error.localizedDescription)
        }
    }
    
    private func deleteVoiceEntryFromFBStorage(_ voiceEntry: VoiceEntry) async throws {
        do {
            let voiceEntryReference = storage.reference(forURL: voiceEntry.downloadURL)
            
            try await voiceEntryReference.delete()
        } catch {
            print(error.emojiMessage)
            throw FBStorageError.deleteDataFailed(systemError: error.localizedDescription)
        }
    }
}
