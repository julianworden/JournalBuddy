//
//  AddEditVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class AddEditVideoEntryView: UIView, MainView {
    private lazy var videoPreview = VideoPreviewView()
    private lazy var startRecordingButton = PrimaryButton(title: "Start Recording")

    var viewModel: AddEditVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        configure()

        Task {
            #warning("Call view model method directly from here instead")
            await setUpVideoCaptureSession()
            constrain()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .background

        startRecordingButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
    }

    func constrain() {
        addConstrainedSubviews(videoPreview, startRecordingButton)

        NSLayoutConstraint.activate([
            videoPreview.topAnchor.constraint(equalTo: topAnchor, constant: -50),
            videoPreview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 50),
            videoPreview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -50),
            videoPreview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 50),

            startRecordingButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func makeAccessible() {

    }
    
    func subscribeToPublishers() {

    }

    func setUpVideoCaptureSession() async {
        await viewModel.setUpVideoCaptureSession()

        #warning("Do this in a published property callback so that it's always called immedately after the session is configured.")
        videoPreview.videoPreviewLayer.session = viewModel.captureSession

        Task.detached { [weak self] in
            // Runtime error will be thrown if this isn't called from background thread
            await self?.viewModel.captureSession.startRunning()
        }
    }

    @objc func startRecording() {
        viewModel.startRecording()
    }
}
