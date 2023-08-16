//
//  EntryTypeCollectionViewDataSourceAndDelegate.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/15/23.
//

import UIKit

class EntryTypeCollectionViewDataSourceAndDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let entryTypeSelector: UICollectionView
    let entryTypeCellRegistration = UICollectionView.CellRegistration<EntryTypeCollectionViewCell, EntryType> { cell, indexPath, entryType in
        cell.configure(with: entryType)
    }

    init(entryTypeSelector: UICollectionView) {
        self.entryTypeSelector = entryTypeSelector
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EntryType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entryType = EntryType.allCases[indexPath.row]

        return collectionView.dequeueConfiguredReusableCell(using: entryTypeCellRegistration, for: indexPath, item: entryType)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let entryType = EntryType.allCases[indexPath.row]

        let textSize = entryType.pluralRawValue.size(withAttributes: [.font: UIFontMetrics.avenirNextBoldBody])
        return CGSize(width: textSize.width + 40, height: textSize.height + 10)
    }
}
