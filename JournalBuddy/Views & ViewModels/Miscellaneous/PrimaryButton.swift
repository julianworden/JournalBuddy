//
//  PrimaryButton.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/16/23.
//

import UIKit

class PrimaryButton: UIButton {
    convenience init(title: String) {
        self.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: .boldTitle3)
        layer.cornerRadius = 12
        backgroundColor = .systemOrange
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
