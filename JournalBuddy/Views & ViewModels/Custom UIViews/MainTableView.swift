//
//  MainTableView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/13/23.
//

import UIKit

class MainTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .background
        separatorColor = .divider
    }
}
