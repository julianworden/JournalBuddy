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

    func fetchEntries<T: Entry>(_ entryType: EntryType) async throws -> [T] {
        do {
            switch entryType {
            case .text:
                return try await fetchTextEntries() as! [T]
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

    func fetchTextEntries() async throws -> [TextEntry] {
        do {
            let query = try await usersCollection
                .document(authService.currentUserUID)
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
}
