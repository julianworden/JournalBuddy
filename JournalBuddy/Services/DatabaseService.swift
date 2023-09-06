//
//  DatabaseService.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

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
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }

    // MARK: - Generic Entry CRUD

    func fetchEntries<T: Entry>(_ entryType: EntryType, forUID uid: String) async throws -> [T] {
        do {
            switch entryType {
            case .text:
                return try await fetchTextEntries(forUID: uid) as! [T]
            default:
                fatalError("No other types of entries have been implemented yet.")
            }
        } catch {
            throw error
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
            default:
                fatalError("No other types of entries have been implemented yet")
            }
        } catch {
            throw error
        }
    }

    func updateEntry<T: Entry>(_ entry: T) async throws {
        do {
            switch entry.type {
            case .text:
                let textEntry = entry as! TextEntry
                try await updateTextEntry(textEntry)
            default:
                fatalError("No other types of entries have been implemented yet")
            }
        } catch {
            throw error
        }
    }

    func deleteEntry<T: Entry>(_ entry: T) async throws {
        do {
            try await usersCollection
                .document(entry.creatorUID)
                .collection(FBConstants.entries)
                .document(entry.id)
                .delete()
        } catch {
            throw error
        }
    }

    // MARK: - TextEntry

    func fetchTextEntries(forUID uid: String) async throws -> [TextEntry] {
        do {
            let query = try await usersCollection
                .document(uid)
                .collection(FBConstants.entries)
                .getDocuments()

            return try query.documents.map { try $0.data(as: TextEntry.self) }
        }
    }

    func saveTextEntry(_ textEntry: TextEntry) async throws -> TextEntry {
        do {
            let newDocument = try usersCollection
                .document(textEntry.creatorUID)
                .collection(FBConstants.entries)
                .addDocument(from: textEntry)

            try await newDocument.updateData([FBConstants.id: newDocument.documentID])
            var textEntryWithID = textEntry
            textEntryWithID.id = newDocument.documentID
            return textEntryWithID
        } catch {
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }

    func updateTextEntry(_ textEntry: TextEntry) async throws {
        do {
            try await usersCollection
                .document(textEntry.creatorUID)
                .collection(FBConstants.entries)
                .document(textEntry.id)
                .updateData([FBConstants.text: textEntry.text])
        } catch {
            throw FBFirestoreError.updateDataFailed(systemError: error.localizedDescription)
        }
    }
    
    // MARK: - VideoEntry
    
    /// Uploads a given video entry to Firestore and then saves that video entry's info in Firestore.
    /// - Parameters:
    ///   - videoEntry: The video entry that is to be saved to Firestore. This argument is not expected to have a valid `downloadURL`
    ///   or `id` property, as those properties will be assigned during this method's execution.
    ///   - url: The local URL on the user's device where the video entry that is to be saved is being stored.
    /// - Returns: The saved video entry, which should have valid `downloadURL` and `id` properties, as they were assigned during
    /// the execution of the method.
    func saveVideoEntry(_ videoEntry: VideoEntry, at url: URL) async throws -> VideoEntry {
        let downloadURL = try await uploadVideoEntryToFBStorage(videoEntry, at: url)
        var newVideoEntry = videoEntry
        newVideoEntry.downloadURL = downloadURL.absoluteString
        
        do {
            let newVideoEntryDocumentReference = try usersCollection
                .document(newVideoEntry.creatorUID)
                .collection(FBConstants.entries)
                .addDocument(from: newVideoEntry)
            try await newVideoEntryDocumentReference
                .updateData([FBConstants.id: newVideoEntryDocumentReference.documentID])
            newVideoEntry.id = newVideoEntryDocumentReference.documentID
            
            return newVideoEntry
        } catch {
            throw FBFirestoreError.saveDataFailed(systemError: error.localizedDescription)
        }
    }
    
    // MARK: - Firebase Storage
    
    /// Uploads a video entry to Firebase Storage.
    /// - Parameters:
    ///   - videoEntry: The video entry to upload to Firebase Storage.
    ///   - url: The local URL on the user's device where the video entry is being stored.
    /// - Returns: The download URL for `videoEntry` that was provided by Firebase Storage. This method's caller should use this
    /// URL as the `videoEntry`'s `downloadURL` property.
    func uploadVideoEntryToFBStorage(_ videoEntry: VideoEntry, at url: URL) async throws -> URL {
        do {
            let newVideoEntryLocationRef = storageRef.child("Video Entries/\(videoEntry.creatorUID)/\(UUID().uuidString).mov")
            
            guard let videoData = try? Data(contentsOf: url) else {
                print("❌ Failed to store video into Data type.")
                throw VideoEntryError.conversionToDataTypeFailed
            }
            
            let metadata = try await newVideoEntryLocationRef.putDataAsync(videoData) { progress in
                
            }
            
            do {
                return try await newVideoEntryLocationRef.downloadURL()
            } catch {
                throw VideoEntryError.failedToFetchDownloadURL
            }
        } catch {
            throw FBStorageError.saveDataFailed(systemError: error.localizedDescription)
        }
    }
}
