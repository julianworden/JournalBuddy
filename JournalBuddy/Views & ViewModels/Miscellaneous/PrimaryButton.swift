//
//  PrimaryButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

class PrimaryButton: UIButton {
    convenience init(title: String) {
        self.init(configuration: .borderedProminent())
        self.init(frame: .zero)

        configure(with: title)
        constrain()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String) {
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .boldBody)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        layer.cornerRadius = 12
        backgroundColor = .systemOrange
    }

    /// Constrains `titleLabel` to the top and bottom of the button to prevent it from overflowing the button's
    /// bounds at higher Dynamic Type settings.
    func constrain() {
        if let titleLabel {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}
