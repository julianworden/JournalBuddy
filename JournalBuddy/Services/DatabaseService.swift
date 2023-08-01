//
//  DatabaseService.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/22/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

final class DatabaseService: DatabaseServiceProtocol {
    private let db = Firestore.firestore()
    private lazy var usersCollection = db.collection(FBConstants.users)

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

    @discardableResult func saveEntry<T: Entry>(_ entry: T) async throws -> T {
        do {
            switch entry.type {
            case .text:
                let textEntry = entry as! TextEntry
                return try await saveTextEntry(textEntry) as! T
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
}
