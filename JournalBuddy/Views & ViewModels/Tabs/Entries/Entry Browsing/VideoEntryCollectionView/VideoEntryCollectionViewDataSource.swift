//
//  VideoEntryCollectionViewDataSource.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/21/23.
//

import Combine
import Foundation
import UIKit

enum VideoEntryCollectionViewSection {
    case main
}

final class VideoEntryCollectionViewDataSource: UICollectionViewDiffableDataSource<VideoEntryCollectionViewSection, VideoEntry> {
    let viewModel: EntriesViewModel
    var cancellables = Set<AnyCancellable>()
    let cellRegistration = UICollectionView.CellRegistration<VideoEntryCollectionViewCell, VideoEntry> { cell, indexPath, videoEntry in
        cell.configure(with: videoEntry)
    }
    
    init(viewModel: EntriesViewModel, collectionView: UICollectionView) {
        self.viewModel = viewModel
        let cellRegistration = UICollectionView.CellRegistration<VideoEntryCollectionViewCell, VideoEntry> { cell, indexPath, videoEntry in
            cell.configure(with: videoEntry)
        }

        super.init(collectionView: collectionView) { collectionView, indexPath, videoEntry in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: videoEntry)
        }
        
        subscribeToPublishers()
    }
    
    func subscribeToPublishers() {
        viewModel.$videoEntries
            .sink { [weak self] videoEntries in
                self?.updateDataSource(with: videoEntries)
            }
            .store(in: &cancellables)
    }
    
    func updateDataSource(with videoEntries: [VideoEntry]) {
        var snapshot = NSDiffableDataSourceSnapshot<VideoEntryCollectionViewSection, VideoEntry>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videoEntries)
        apply(snapshot)
    }
}
