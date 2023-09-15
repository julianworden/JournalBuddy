//
//  TimerView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/15/23.
//

import UIKit

class TimerView: UIView {
    private lazy var background = UIView()
    /// Displays how long the user has been recording.
    private lazy var timerLabel = UILabel()
    
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
        background.backgroundColor = .primaryElement
        background.layer.cornerRadius = 12

        timerLabel.text = "00:00 / 05:00"
        timerLabel.textColor = .background
        timerLabel.font = UIFontMetrics.avenirNextRegularBody
        timerLabel.numberOfLines = 0
        timerLabel.textAlignment = .center
    }
    
    func makeAccessible() {
        timerLabel.adjustsFontForContentSizeCategory = true
    }
    
    func constrain() {
        addConstrainedSubview(background)
        background.addConstrainedSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: background.topAnchor, constant: 7),
            timerLabel.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -7),
            timerLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 15),
            timerLabel.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -15),
        ])
    }
    
    /// Allows the parent view to conveniently update `timerLabel`'s text.
    /// - Parameter text: The text that will be assigned to `timerLabel`.
    func updateTimerLabelText(with text: String) {
        timerLabel.text = text
    }
}
