//
//  WatchVideoEntryViewState.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/24/23.
//

import UIKit

enum WatchVideoEntryViewState: ViewState {
    case displayingView
    case fetchingVideoEntry
    case fetchedVideoEntry
    case deletingVideoEntry
    case deletedVideoEntry
    case error(message: String)
}
