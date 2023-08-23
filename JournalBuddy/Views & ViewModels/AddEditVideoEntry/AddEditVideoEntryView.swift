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
    private lazy var startRecordingButton = UIView()
    private lazy var startRecordingButtonInnerRedView = UIView()

    private lazy var startRecordingTapGesture = UITapGestureRecognizer(target: self, action: #selector(startRecording))
    private lazy var stopRecordingTapGesture = UITapGestureRecognizer(target: self, action: #selector(stopRecording))

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

    override func layoutSubviews() {
        super.layoutSubviews()

        startRecordingButton.layer.cornerRadius = startRecordingButton.bounds.size.width / 2
        startRecordingButtonInnerRedView.layer.cornerRadius = startRecordingButton.bounds.size.width / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .background

        startRecordingButton.backgroundColor = .clear
        startRecordingButton.layer.borderWidth = 3
        startRecordingButton.layer.borderColor = UIColor.background.cgColor
        let startRecordingTapGesture = UITapGestureRecognizer(target: self, action: #selector(startRecording))
        startRecordingButton.addGestureRecognizer(startRecordingTapGesture)

        startRecordingButtonInnerRedView.clipsToBounds = true
        startRecordingButtonInnerRedView.backgroundColor = .destructive
    }

    func constrain() {
        addConstrainedSubviews(videoPreview, startRecordingButton)
        startRecordingButton.addConstrainedSubviews(startRecordingButtonInnerRedView)

        NSLayoutConstraint.activate([
            videoPreview.topAnchor.constraint(equalTo: topAnchor, constant: -50),
            videoPreview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 50),
            videoPreview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -50),
            videoPreview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 50),

            startRecordingButton.heightAnchor.constraint(equalToConstant: 80),
            startRecordingButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            startRecordingButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startRecordingButton.widthAnchor.constraint(equalToConstant: 80),

            startRecordingButtonInnerRedView.topAnchor.constraint(equalTo: startRecordingButton.topAnchor),
            startRecordingButtonInnerRedView.bottomAnchor.constraint(equalTo: startRecordingButton.bottomAnchor),
            startRecordingButtonInnerRedView.leadingAnchor.constraint(equalTo: startRecordingButton.leadingAnchor),
            startRecordingButtonInnerRedView.trailingAnchor.constraint(equalTo: startRecordingButton.trailingAnchor)
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
        startRecordingButton.removeGestureRecognizer(startRecordingTapGesture)
        startRecordingButton.addGestureRecognizer(stopRecordingTapGesture)

        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.startRecordingButtonInnerRedView.layer.cornerRadius = 8
            self?.startRecordingButtonInnerRedView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }

        viewModel.startRecording()
    }

    @objc func stopRecording() {
        startRecordingButton.removeGestureRecognizer(stopRecordingTapGesture)
        startRecordingButton.addGestureRecognizer(startRecordingTapGesture)

        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }

            self.startRecordingButtonInnerRedView.layer.cornerRadius = self.startRecordingButton.bounds.size.width / 2
            self.startRecordingButtonInnerRedView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }

        viewModel.stopRecording()
    }
}
