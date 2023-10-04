//
//  VoiceEntryCollectionViewDataSource.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/26/23.
//

import Combine
import UIKit

enum VoiceEntryCollectionViewDataSourceSection {
    case main
}

@MainActor
final class VoiceEntryCollectionViewDataSource: UICollectionViewDiffableDataSource<VoiceEntryCollectionViewDataSourceSection, VoiceEntry> {
    let viewModel: EntriesViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(collectionView: UICollectionView, viewModel: EntriesViewModel) {
        self.viewModel = viewModel
        
        let cellRegistration = UICollectionView.CellRegistration<VoiceEntryCollectionViewCell, VoiceEntry> { cell, indexPath, voiceEntry in
            cell.configure(with: voiceEntry)
        }
        
        super.init(collectionView: collectionView) { collectionView, indexPath, voiceEntry in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: voiceEntry)
        }
        
        subscribeToPublishers()
    }
    
    func subscribeToPublishers() {
        viewModel.$voiceEntries
            .sink { [weak self] voiceEntries in
                self?.updateDataSource(with: voiceEntries)
            }
            .store(in: &cancellables)

    }
    
    func updateDataSource(with voiceEntries: [VoiceEntry]) {
        var snapshot = NSDiffableDataSourceSnapshot<VoiceEntryCollectionViewDataSourceSection, VoiceEntry>()
        snapshot.appendSections([.main])
        snapshot.appendItems(voiceEntries)
        
        apply(snapshot)
    }
}
