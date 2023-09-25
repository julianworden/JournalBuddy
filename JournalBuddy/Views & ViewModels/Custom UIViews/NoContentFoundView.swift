//
//  NoContentFoundView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/24/23.
//

import UIKit

class NoContentFoundView: UIView {
    private lazy var contentStack = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var messageLabel = UILabel()
    
    init(
        image: UIImage = UIImage(
            systemName: "magnifyingglass",
            withConfiguration: .primaryElementColor
        )!.applyingSymbolConfiguration(
            UIImage.SymbolConfiguration(
                textStyle: .title3
            )
        )!,
        title: String,
        message: String
    ) {
        super.init(frame: .zero)
        
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
        
        configure()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        contentStack.axis = .vertical
        contentStack.spacing = 5
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = UIFontMetrics.avenirNextBoldBody
        titleLabel.textColor = .primaryElement
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        messageLabel.font = UIFontMetrics.avenirNextRegularBody
        messageLabel.textColor = .primaryElement
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
    }
    
    func constrain() {
        addConstrainedSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func updateTitle(to newTitle: String) {
        titleLabel.text = newTitle
    }
    
    func updateSubtitle(to newSubtitle: String) {
        messageLabel.text = newSubtitle
    }
}
