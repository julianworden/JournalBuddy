//
//  MockDatabaseService.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

@testable import JournalBuddy
import Foundation

final class MockDatabaseService: DatabaseServiceProtocol {
    var errorToThrow: Error?

    init(errorToThrow: Error?) {
        self.errorToThrow = errorToThrow
    }

    // MARK: - User

    func getUser(withUID uid: String) async throws -> User {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return User.example
        }
    }

    func createUser(_ user: JournalBuddy.User) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    // MARK: - Generic Entry CRUD

    func fetchEntries<T: Entry>(_ entryType: EntryType, forUID uid: String) async throws -> [T] {
        if let errorToThrow {
            throw errorToThrow
        } else {
            return TestData.textEntryArray as! [T]
        }
    }

    func saveEntry<T: Entry>(_ entry: T, at url: URL?) async throws -> T {
        do {
            switch entry.type {
            case .text:
                return try await saveTextEntry(entry as! TextEntry) as! T
            case .video:
                return try await saveVideoEntry(entry as! VideoEntry, at: url!) as! T
            default:
                fatalError("Entry type not implemented.")
            }
        } catch {
            throw error
        }
    }

    func updateEntry<T: Entry>(_ entry: T) async throws {
        do {
            switch entry.type {
            case .text:
                try await updateTextEntry(entry as! TextEntry)
            default:
                fatalError("Entry type not implemented.")
            }
        } catch {
            throw error
        }
    }

    func deleteEntry<T: Entry>(_ entry: T) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }

    // MARK: - TextEntry

    func fetchTextEntries(forUID uid: String) async throws -> [TextEntry] {
        return []
    }

    func saveTextEntry(_ textEntry: TextEntry) async throws -> TextEntry {
        if let errorToThrow {
            throw errorToThrow
        } else {
            var textEntryWithID = textEntry
            textEntryWithID.id = UUID().uuidString
            return textEntryWithID
        }
    }

    func updateTextEntry(_ textEntry: TextEntry) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }
    
    // MARK: - VideoEntry
    
    func saveVideoEntry(_ videoEntry: VideoEntry, at url: URL) async throws -> VideoEntry {
        if let errorToThrow {
            throw errorToThrow
        } else {
            var newVideoEntry = videoEntry
            newVideoEntry.downloadURL = "https://exampledownloadurl.com"
            newVideoEntry.id = UUID().uuidString
            newVideoEntry.downloadURL = "https://examplethumbnaildownloadurl.com"
            return newVideoEntry
        }
    }
    
    // MARK: - Firebase Storage
    
    func uploadVideoEntryToFBStorage(_ videoEntry: VideoEntry, at url: URL) async throws -> URL {
        if let errorToThrow {
            throw errorToThrow
        }
        
        return url
    }
    
    func uploadVideoEntryThumbnailToFBStorage(videoEntry: VideoEntry, videoEntryLocalURL: URL) async throws -> URL {
        if let errorToThrow {
            throw errorToThrow
        }
        
        return videoEntryLocalURL
    }
}
