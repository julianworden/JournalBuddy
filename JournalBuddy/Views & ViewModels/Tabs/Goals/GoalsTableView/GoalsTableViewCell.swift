//
//  GoalsTableViewCell.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import UIKit

class GoalsTableViewCell: UITableViewCell {
    let circleImage = UIImage(
        systemName: "circle",
        withConfiguration: .largeScale.applying(.primaryElementColor)
    )!
    let checkmarkImage = UIImage(
        systemName: "checkmark.circle.fill",
        withConfiguration: .largeScale.applying(.primaryElementColor)
    )!
    
    private lazy var contentStack = UIStackView(arrangedSubviews: [
        goalNameLabel,
        completeGoalButton,
        completingGoalActivityIndicator
    ])
    private lazy var goalNameLabel = UILabel()
    private var completeGoalButton: SFSymbolButton!
    private lazy var completingGoalActivityIndicator = UIActivityIndicatorView(style: .medium)
    
    static let reuseIdentifier = "GoalsTableViewCell"
    var viewModel: GoalsViewModel!
    var goal: Goal!
    
    var completeGoalButtonImage: UIImage {
        if goal.isComplete {
            return checkmarkImage
        } else {
            return circleImage
        }
    }
    
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
        self.goal = goal
        
        goalNameLabel.text = goal.name
        goalNameLabel.font = UIFontMetrics.avenirNextRegularBody
        goalNameLabel.textColor = .primaryElement
        goalNameLabel.numberOfLines = 0
        goalNameLabel.lineBreakMode = .byCharWrapping
        
        completeGoalButton = SFSymbolButton(symbol: completeGoalButtonImage)
        if !goal.isComplete {
            completeGoalButton.addTarget(
                self,
                action: #selector(completeGoalButtonTapped),
                for: .touchUpInside
            )
        }
        completeGoalButton.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        completingGoalActivityIndicator.hidesWhenStopped = true
        completingGoalActivityIndicator.isHidden = true
        
        contentStack.distribution = .equalCentering
        
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
    
    private func shrinkCompleteGoalButton(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                self?.completeGoalButton.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            },
            completion: { _ in completion() }
        )
    }
    
    private func enlargeCompleteGoalButton(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            animations: { [weak self] in
                self?.completeGoalButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            },
            completion: { _ in completion() }
        )
    }
    
    private func completeGoal() async {
        do {
            try await self.viewModel.completeGoal(self.goal)
        } catch {
            print(error.emojiMessage)
            // Reset button if anything goes wrong
            self.completeGoalButton.setImage(self.circleImage, for: .normal)
            self.completeGoalButton.addTarget(
                self,
                action: #selector(self.completeGoalButtonTapped),
                for: .touchUpInside
            )
        }
    }
    
    @objc func completeGoalButtonTapped() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        shrinkCompleteGoalButton { [weak self] in
            guard let self else { return }
            
            self.completeGoalButton.setImage(self.checkmarkImage, for: .normal)
            
            self.enlargeCompleteGoalButton {
                Task {
                    await self.completeGoal()
                    // Without this, checkmark image will still appear after completing the last incomplete goal and then completing a new one
                    self.completeGoalButton.setImage(self.circleImage, for: .normal)
                }
            }
        }
    }
}
