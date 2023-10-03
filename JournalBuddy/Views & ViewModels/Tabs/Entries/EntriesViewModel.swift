//
//  EntriesViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on  7/21/23.
//

import Combine
import Foundation

@MainActor
final class EntriesViewModel: MainViewModel {
    enum SelectedEntryType {
        case text, video, voice
    }
    
    @Published var customMenuIsShowing = false
    @Published var textEntries = [TextEntry]()
    @Published var videoEntries = [VideoEntry]()
    @Published var voiceEntries = [VoiceEntry]()
    @Published var viewState = EntriesViewState.fetchingTextEntries
    var selectedEntryType = SelectedEntryType.text
    /// Establishes whether or not the view model has ever queried Firestore for text entries. This property is used
    /// in the view to determine the behavior of the view when navigating between entry types.
    var textEntriesQueryPerformed = false
    /// Establishes whether or not the view model has ever queried Firestore for video entries. This property is used
    /// in the view to determine the behavior of the view when navigating between entry types.
    var videoEntriesQueryPerformed = false
    /// Establishes whether or not the view model has ever queried Firestore for voice entries. This property is used
    /// in the view to determine the behavior of the view when navigating between entry types.
    var voiceEntriesQueryPerformed = false

    var cancellables = Set<AnyCancellable>()
    let databaseService: DatabaseServiceProtocol
    let authService: AuthServiceProtocol
    let currentUser: User
    
    var entryQueryHasBeenPerformed: Bool {
        return textEntriesQueryPerformed ||
               videoEntriesQueryPerformed ||
               voiceEntriesQueryPerformed
    }

    init(
        databaseService: DatabaseServiceProtocol,
        authService: AuthServiceProtocol,
        currentUser: User
    ) {
        self.databaseService = databaseService
        self.authService = authService
        self.currentUser = currentUser
    }

    /// Fetches all of the logged in user's text entries.
    /// - Parameter performEntryQuery: Makes it possible to test case where no text entries are found. Defaults to true
    /// because this property should never be used in production.
    func fetchFirstTextEntriesBatch(performEntryQuery: Bool = true) async {
        do {
            viewState = .fetchingTextEntries
            if performEntryQuery {
                textEntries = try await databaseService.fetchFirstEntriesBatch(.text, forUID: currentUser.uid)
            }

            if textEntries.isEmpty {
                viewState = .noTextEntriesFound
            } else {
                viewState = .fetchedTextEntries
            }
            
            textEntriesQueryPerformed = true
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func fetchNextTextEntriesBatch() async {
        do {
            guard let oldestTextEntry = textEntries.last else {
                print("❌ Attempted to fetch next text entries batch while textEntries array is empty.")
                return
            }
            
            let nextTextEntriesBatch = try await databaseService.fetchNextEntriesBatch(
                after: oldestTextEntry,
                forUID: currentUser.uid
            )
            textEntries.append(contentsOf: nextTextEntriesBatch)
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Fetches all of the logged in user's video entries.
    /// - Parameter performEntryQuery: Makes it possible to test case where no video entries are found. Defaults to true
    /// because this property should never be used in production.
    func fetchVideoEntries(performEntryQuery: Bool = true) async {
        do {
            viewState = .fetchingVideoEntries
            if performEntryQuery {
                videoEntries = try await databaseService.fetchFirstEntriesBatch(.video, forUID: currentUser.uid)
            }
            
            if videoEntries.isEmpty {
                viewState = .noVideoEntriesFound
            } else {
                viewState = .fetchedVideoEntries
            }
            
            videoEntriesQueryPerformed = true
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Fetches all of the logged in user's voice entries.
    /// - Parameter performEntryQuery: Makes it possible to test case where no voice entries are found. Defaults to true
    /// because this property should never be used in production.
    func fetchVoiceEntries(performEntryQuery: Bool = true) async {
        do {
            viewState = .fetchingVoiceEntries
            if performEntryQuery {
                voiceEntries = try await databaseService.fetchFirstEntriesBatch(.voice, forUID: currentUser.uid)
            }
            
            if voiceEntries.isEmpty {
                viewState = .noVoiceEntriesFound
            } else {
                viewState = .fetchedVoiceEntries
            }
            
            voiceEntriesQueryPerformed = true
        } catch {
            print(error.emojiMessage)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func subscribeToPublishers() {
        subscribeToTextEntryCreatedNotification()
        subscribeToTextEntryUpdatedNotification()
        subscribeToTextEntryDeletedNotification()
        subscribeToVideoEntryCreatedNotification()
        subscribeToVideoEntryDeletedNotification()
        subscribeToVoiceEntryWasCreatedNotification()
        subscribeToVoiceEntryDeletedNotification()
    }
    
    func subscribeToTextEntryCreatedNotification() {
        NotificationCenter.default.publisher(for: .textEntryWasCreated)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let createdTextEntry = notification.userInfo?[NotificationConstants.createdTextEntry] as? TextEntry else {
                    print("❌ createdTextEntry notification posted without entry info.")
                    return
                }
                
                self.textEntries.insert(createdTextEntry, at: 0)
                
                if selectedEntryType == .text && self.viewState != .fetchedTextEntries {
                    self.viewState = .fetchedTextEntries
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToTextEntryUpdatedNotification() {
        NotificationCenter.default.publisher(for: .textEntryWasUpdated)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let updatedTextEntry = notification.userInfo?[NotificationConstants.updatedTextEntry] as? TextEntry else {
                    print("❌ updatedTextEntry notification posted without entry info.")
                    return
                }
                
                guard let updatedTextEntryIndex = self.textEntries.firstIndex(where: {
                    $0.id == updatedTextEntry.id
                }) else {
                    print("❌ updated text entry not found in textEntries array.")
                    return
                }
                
                self.textEntries[updatedTextEntryIndex] = updatedTextEntry
            }
            .store(in: &cancellables)
    }
    
    func subscribeToTextEntryDeletedNotification() {
        NotificationCenter.default.publisher(for: .textEntryWasDeleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let deletedTextEntry = notification.userInfo?[NotificationConstants.deletedTextEntry] as? TextEntry else {
                    print("❌ deletedTextEntry notification posted without entry info.")
                    return
                }
                
                guard let deletedTextEntryIndex = self.textEntries.firstIndex(of: deletedTextEntry) else {
                    print("❌ deleted text entry not found in textEntries array.")
                    return
                }
                
                self.textEntries.remove(at: deletedTextEntryIndex)
                
                if self.textEntries.isEmpty {
                    self.viewState = .noTextEntriesFound
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVideoEntryCreatedNotification() {
        NotificationCenter.default.publisher(for: .videoEntryWasCreated)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let createdVideoEntry = notification.userInfo?[NotificationConstants.createdVideoEntry] as? VideoEntry else {
                    print("❌ videoEntryWasCreated notification posted without entry info.")
                    return
                }
                
                videoEntries.append(createdVideoEntry)
                
                if selectedEntryType == .video && self.viewState != .fetchedVideoEntries {
                    self.viewState = .fetchedVideoEntries
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVideoEntryDeletedNotification() {
        NotificationCenter.default.publisher(for: .videoEntryWasDeleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let deletedVideoEntry = notification.userInfo?[NotificationConstants.deletedVideoEntry] as? VideoEntry else {
                    print("❌ videoEntryWasDeleted notification posted without entry info.")
                    return
                }
                
                guard let deletedVideoEntryIndex = self.videoEntries.firstIndex(of: deletedVideoEntry) else {
                    print("❌ deleted video entry not found in videoEntries array.")
                    return
                }
                
                self.videoEntries.remove(at: deletedVideoEntryIndex)
                
                if self.videoEntries.isEmpty {
                    self.viewState = .noVideoEntriesFound
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVoiceEntryWasCreatedNotification() {
        NotificationCenter.default.publisher(for: .voiceEntryWasCreated)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let createdVoiceEntry = notification.userInfo?[NotificationConstants.createdVoiceEntry] as? VoiceEntry else {
                    print("❌ voiceEntryWasCreated notification posted without entry info.")
                    return
                }
                
                voiceEntries.append(createdVoiceEntry)
                
                if selectedEntryType == .voice && self.viewState != .fetchedVoiceEntries {
                    self.viewState = .fetchedVoiceEntries
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVoiceEntryDeletedNotification() {
        NotificationCenter.default.publisher(for: .voiceEntryWasDeleted)
            .sink { [weak self] notification in
                guard let self else { return }
                
                guard let deletedVoiceEntry = notification.userInfo?[NotificationConstants.deletedVoiceEntry] as? VoiceEntry else {
                    print("❌ voiceEntryWasDeleted notification posted without entry info.")
                    return
                }
                
                guard let deletedVoiceEntryIndex = self.voiceEntries.firstIndex(of: deletedVoiceEntry) else {
                    print("❌ deleted voice entry not found in videoEntries array.")
                    return
                }
                
                self.voiceEntries.remove(at: deletedVoiceEntryIndex)
                
                if self.voiceEntries.isEmpty {
                    self.viewState = .noVoiceEntriesFound
                }
            }
            .store(in: &cancellables)
    }
}
