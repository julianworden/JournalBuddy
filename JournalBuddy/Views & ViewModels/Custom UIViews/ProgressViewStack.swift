//
//  ProgressViewStack.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/16/23.
//

import UIKit

class ProgressViewStack: UIStackView {
    private lazy var progressView = UIProgressView(progressViewStyle: .bar)
    private lazy var labelStack = UIStackView(arrangedSubviews: [label, labelActivityIndicator])
    private lazy var label = UILabel()
    private lazy var labelActivityIndicator = UIActivityIndicatorView(style: .medium)
        
    init() {
        super.init(frame: .zero)
        
        configure()
        makeAccessible()
        constrain()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        axis = .vertical
        spacing = 7
        alignment = .leading
        
        progressView.layer.cornerRadius = 6
        progressView.clipsToBounds = true
        progressView.progressTintColor = .primaryElement
        progressView.trackTintColor = .disabled
        
        labelStack.spacing = 5
        
        label.font = UIFontMetrics.avenirNextBoldFootnote
        label.textColor = .primaryElement
        label.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        labelActivityIndicator.hidesWhenStopped = true
        labelActivityIndicator.isHidden = true
        labelActivityIndicator.color = .primaryElement
    }
    
    func constrain() {
        addArrangedSubview(progressView)
        addArrangedSubview(labelStack)
        
        NSLayoutConstraint.activate([
            progressView.heightAnchor.constraint(equalToConstant: 12),
            progressView.widthAnchor.constraint(equalToConstant: 270)
        ])
    }
    
    func makeAccessible() {
        label.adjustsFontForContentSizeCategory = true
    }
    
    func presentActivityIndicator() {
        labelActivityIndicator.startAnimating()
        labelActivityIndicator.isHidden = false
    }
    
    func hideActivityIndicator() {
        labelActivityIndicator.isHidden = true
    }
    
    func updateLabelText(to newText: String) {
        label.text = newText
    }
    
    func updateProgress(to newProgress: Float) {
        progressView.setProgress(newProgress, animated: true)
    }
}
