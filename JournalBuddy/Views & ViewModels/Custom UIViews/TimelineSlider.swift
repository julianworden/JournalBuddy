//
//  TimelineSlider.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/16/23.
//

import UIKit

class TimelineSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        tintColor = .primaryElement
        minimumValue = 0
        maximumValue = 1
        thumbTintColor = .background
        maximumTrackTintColor = .disabled
        isContinuous = false
    }
}
