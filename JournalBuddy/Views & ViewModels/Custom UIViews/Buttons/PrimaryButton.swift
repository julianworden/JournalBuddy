//
//  PrimaryButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

class PrimaryButton: UIButton {
    enum ButtonState {
        case normal, disabled
    }

    var disabledColor = UIColor.disabled
    var normalColor = UIColor.primaryElement

    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = normalColor
            } else {
                backgroundColor = disabledColor
            }
        }
    }

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
        setTitleColor(.primaryButtonText, for: .normal)
        titleLabel?.font = UIFontMetrics.avenirNextBoldBody
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.adjustsFontForContentSizeCategory = true
        layer.cornerRadius = 12
        backgroundColor = normalColor

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
    }

    /// Constrains `titleLabel` to the top and bottom of the button to prevent it from overflowing the button's
    /// bounds at higher Dynamic Type settings.
    func constrain() {
        if let titleLabel {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
                titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15)
            ])
        }
    }

    /// Changes the background color of the button as soon as it's touched.
    @objc func touchDown(_ sender: UIButton) {
        backgroundColor = disabledColor
    }

    /// Changes the background color of the button as soon as it's released after being touched.
    @objc func touchUpInside(_ sender: UIButton) {
        backgroundColor = normalColor
    }

    /// Changes the background color of the button as soon as it's released from outside of the bounds
    /// of the button after being touched.
    @objc func touchUpOutside(_ sender: UIButton) {
        backgroundColor = normalColor
    }
}
