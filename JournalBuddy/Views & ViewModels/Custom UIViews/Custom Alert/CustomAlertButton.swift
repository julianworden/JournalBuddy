//
//  CustomAlertButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/17/23.
//

import UIKit

class CustomAlertButton: UIButton {
    let text: String

    init(text: String) {
        self.text = text

        super.init(frame: .zero)

        configure()
        makeAccessible()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        setTitle(text, for: .normal)
        setTitleColor(.primaryElement, for: .normal)
        titleLabel?.font = UIFontMetrics.avneirNextDemiBoldBody

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
    }

    func makeAccessible() {
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    /// Changes the background color of the button as soon as it's touched.
    @objc func touchDown(_ sender: UIButton) {
        backgroundColor = .selectedButtonWithGroupedBackground
    }

    /// Changes the background color of the button as soon as it's released after being touched.
    @objc func touchUpInside(_ sender: UIButton) {
        backgroundColor = .groupedBackground
    }

    @objc func touchUpOutside(_ sender: UIButton) {
        backgroundColor = .groupedBackground
    }
}
