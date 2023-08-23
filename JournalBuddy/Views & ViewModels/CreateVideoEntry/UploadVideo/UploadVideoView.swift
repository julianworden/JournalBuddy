//
//  UploadVideoView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import UIKit

class UploadVideoView: UIView, MainView {
    var viewModel: UploadVideoViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: UploadVideoViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .background
    }

    func constrain() {

    }
    
    func makeAccessible() {

    }
    
    func subscribeToPublishers() {

    }
}
