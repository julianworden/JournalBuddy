//
//  HomeYourLatestEntriesCard.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/11/23.
//

import UIKit

class HomeYourLatestEntriesCard: UIView {
    private lazy var cardBackground = OrangeYellowGradientBackground()
    private lazy var headerLabel = UILabel()
    private lazy var carouselCollectionView = UICollectionView(frame: .zero, collectionViewLayout: getCollectionViewLayout())
    let collectionViewCellConfiguration = UICollectionView.CellRegistration<HomeYourLatestEntriesCollectionViewCell, TextEntry> { cell, indexPath, entry in
        cell.configure(with: entry)
    }
    private lazy var pageControl = UIPageControl()

    private var currentPageIndex = 0 {
        didSet {
            pageControl.currentPage = currentPageIndex
        }
    }

    let entries = [
        TextEntry(id: "awoeifjaw;oefij", creatorUID: "asdfoiawj;ef", unixDateCreated: 398475351, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea"),
        TextEntry(id: "awejfawpoeifj", creatorUID: "owiejfwioef", unixDateCreated: 6482047, text: "Commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        makeAccessible()
        constrain()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        layer.cornerRadius = 15
        clipsToBounds = true

        headerLabel.text = "Your Latest Entries"
        headerLabel.numberOfLines = 0
        headerLabel.textAlignment = .center
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldTitle2)
        headerLabel.textColor = .white

        carouselCollectionView.dataSource = self
        carouselCollectionView.delegate = self
        carouselCollectionView.isPagingEnabled = true
        carouselCollectionView.showsHorizontalScrollIndicator = false
        carouselCollectionView.backgroundColor = .clear

        pageControl.currentPage = currentPageIndex
        pageControl.numberOfPages = entries.count
        pageControl.direction = .leftToRight
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .lightGray.withAlphaComponent(0.4)
        // Disables tapping a page, which is not supported at this time
        pageControl.isUserInteractionEnabled = false
    }

    func getCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }

    func makeAccessible() {
        headerLabel.adjustsFontForContentSizeCategory = true
    }

    func constrain() {
        addConstrainedSubviews(cardBackground, headerLabel, carouselCollectionView, pageControl)

        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: trailingAnchor),

            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            carouselCollectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            carouselCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            carouselCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            pageControl.topAnchor.constraint(equalTo: carouselCollectionView.bottomAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    func getCurrentPageIndex() -> Int {
        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }

        return currentPageIndex
    }
}

extension HomeYourLatestEntriesCard: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entry = entries[indexPath.row]

        return collectionView.dequeueConfiguredReusableCell(using: collectionViewCellConfiguration, for: indexPath, item: entry)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPageIndex = getCurrentPageIndex()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPageIndex = getCurrentPageIndex()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPageIndex = getCurrentPageIndex()
    }
}
