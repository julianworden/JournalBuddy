//
//  CreateVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class CreateVideoEntryView: UIView, MainView {
    private lazy var backButton = SFSymbolButton(symbol: UIImage(systemName: "chevron.left.circle.fill", withConfiguration: .largeScale)!.withTintColor(.primaryElement))
    private lazy var videoPreview = VideoPreviewView()
    private lazy var startRecordingButton = UIView()
    private lazy var startRecordingButtonInnerRedView = UIView()

    private lazy var startRecordingTapGesture = UITapGestureRecognizer(target: self, action: #selector(startRecording))
    private lazy var stopRecordingTapGesture = UITapGestureRecognizer(target: self, action: #selector(stopRecording))

    weak var delegate: CreateVideoEntryViewDelegate?
    var viewModel: CreateVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()

    init(viewModel: ViewModel, delegate: CreateVideoEntryViewDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate

        super.init(frame: .zero)

        Task {
            configure()
            await configureVideoPreview()
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

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        // Fill the bounds of the button with the image
        backButton.contentHorizontalAlignment = .fill
        backButton.contentVerticalAlignment = .fill

        clipsToBounds = true

        startRecordingButton.backgroundColor = .clear
        startRecordingButton.layer.borderWidth = 3
        startRecordingButton.layer.borderColor = UIColor.background.cgColor
        let startRecordingTapGesture = UITapGestureRecognizer(target: self, action: #selector(startRecording))
        startRecordingButton.addGestureRecognizer(startRecordingTapGesture)

        startRecordingButtonInnerRedView.clipsToBounds = true
        startRecordingButtonInnerRedView.backgroundColor = .destructive
    }

    func constrain() {
        addConstrainedSubviews(videoPreview, startRecordingButton, backButton)
        startRecordingButton.addConstrainedSubviews(startRecordingButtonInnerRedView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 44),

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

    func configureVideoPreview() async {
        await viewModel.setUpVideoCaptureSession()
        videoPreview.videoPreviewLayer.session = viewModel.captureSession

        Task.detached { [weak self] in
            // Runtime error will be thrown if this isn't called from background thread
            await self?.viewModel.captureSession.startRunning()
        }
    }

    @objc func startRecording() {
        startRecordingButton.removeGestureRecognizer(startRecordingTapGesture)
        startRecordingButton.addGestureRecognizer(stopRecordingTapGesture)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.startRecordingButtonInnerRedView.layer.cornerRadius = 8
            self?.startRecordingButtonInnerRedView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }

        viewModel.startRecording()
    }

    @objc func stopRecording() {
        startRecordingButton.removeGestureRecognizer(stopRecordingTapGesture)
        startRecordingButton.addGestureRecognizer(startRecordingTapGesture)

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }

            self.startRecordingButtonInnerRedView.layer.cornerRadius = self.startRecordingButton.bounds.size.width / 2
            self.startRecordingButtonInnerRedView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }

        viewModel.stopRecording()
    }

    @objc func backButtonTapped() {
        delegate?.addEditVideoEntryViewShouldDismiss()
    }
}
