//
//  GoalsTableViewCell.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import UIKit

class GoalsTableViewCell: UITableViewCell {
    private lazy var circleImage = UIImage(
        systemName: "circle",
        withConfiguration: .largeScale.applying(.primaryElementColor)
    )!
    
    private lazy var contentStack = UIStackView(arrangedSubviews: [
        goalNameLabel,
        completeGoalButton
    ])
    private lazy var goalNameLabel = UILabel()
    private lazy var completeGoalButton = SFSymbolButton(symbol: circleImage)
    
    static let reuseIdentifier = "GoalsTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with goal: Goal) {
        let selectedCellBackgroundView = UIView()
        selectedCellBackgroundView.backgroundColor = .groupedBackground
        selectedCellBackgroundView.clipsToBounds = true
        selectedBackgroundView = selectedCellBackgroundView
        backgroundColor = .background
        
        contentStack.distribution = .equalCentering
        
        goalNameLabel.text = goal.name
        goalNameLabel.font = UIFontMetrics.avenirNextRegularBody
        goalNameLabel.textColor = .primaryElement
        goalNameLabel.numberOfLines = 0
        
        makeAccessible()
        constrain()
    }
    
    func makeAccessible() {
        goalNameLabel.adjustsFontForContentSizeCategory = true
    }
    
    func constrain() {
        contentView.addConstrainedSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
