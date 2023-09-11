//
//  CreateVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import Combine
import UIKit

class CreateVideoEntryView: UIView, MainView {
    private lazy var backButtonImage = UIImage(
        systemName: "chevron.left.circle.fill",
        withConfiguration: .createVideoViewButton
    )!
    private lazy var switchCameraButtonImage = UIImage(
        systemName: "arrow.triangle.2.circlepath.circle.fill",
        withConfiguration: .createVideoViewButton
    )!
    private lazy var showVideoPickerImage = UIImage(
        systemName: "photo.circle.fill",
        withConfiguration: .createVideoViewButton
    )!

    lazy var backButton = SFSymbolButton(symbol: backButtonImage)
    private lazy var recordingTimerLabelBackground = UIView()
    /// Displays how long the user has been recording.
    lazy var recordingTimerLabel = UILabel()
    lazy var switchCameraButton = SFSymbolButton(symbol: switchCameraButtonImage)
    lazy var showVideoPickerButton = SFSymbolButton(symbol: showVideoPickerImage)
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
            makeAccessible()
            constrain()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        startRecordingButton.layer.cornerRadius = startRecordingButton.bounds.size.width / 2

        // layoutSubviews is called when the timer updates. Without this check, the startRecordingButtonInnerRedView
        // becomes a circle while video is still being recorded.
        if viewModel.recordingTimerStartDate == nil {
            startRecordingButtonInnerRedView.layer.cornerRadius = startRecordingButton.bounds.size.width / 2
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        clipsToBounds = true
        backgroundColor = .background

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        // Fill the bounds of the button with the image
        backButton.contentHorizontalAlignment = .fill
        backButton.contentVerticalAlignment = .fill
        backButton.contentMode = .scaleAspectFit

        recordingTimerLabelBackground.backgroundColor = .primaryElement
        recordingTimerLabelBackground.layer.cornerRadius = 12

        recordingTimerLabel.text = "00:00 / 05:00"
        recordingTimerLabel.textColor = .background
        recordingTimerLabel.font = UIFontMetrics.avenirNextRegularBody
        recordingTimerLabel.numberOfLines = 0
        recordingTimerLabel.textAlignment = .center

        switchCameraButton.addTarget(self, action: #selector(switchCameraButtonTapped), for: .touchUpInside)
        switchCameraButton.contentHorizontalAlignment = .fill
        switchCameraButton.contentVerticalAlignment = .fill
        switchCameraButton.contentMode = .scaleAspectFit
        
        showVideoPickerButton.addTarget(self, action: #selector(showVideoPickerButtonTapped), for: .touchUpInside)
        showVideoPickerButton.contentHorizontalAlignment = .fill
        showVideoPickerButton.contentVerticalAlignment = .fill
        showVideoPickerButton.contentMode = .scaleAspectFit

        startRecordingButton.backgroundColor = .clear
        startRecordingButton.layer.borderWidth = 3
        startRecordingButton.layer.borderColor = UIColor.background.cgColor
        let startRecordingTapGesture = UITapGestureRecognizer(target: self, action: #selector(startRecording))
        startRecordingButton.addGestureRecognizer(startRecordingTapGesture)

        startRecordingButtonInnerRedView.clipsToBounds = true
        startRecordingButtonInnerRedView.backgroundColor = .destructive
    }

    func makeAccessible() {
        recordingTimerLabel.adjustsFontForContentSizeCategory = true
    }
    
    func subscribeToPublishers() {

    }

    func constrain() {
        addConstrainedSubviews(
            videoPreview,
            backButton,
            recordingTimerLabelBackground,
            switchCameraButton,
            showVideoPickerButton,
            startRecordingButton
        )
        recordingTimerLabelBackground.addConstrainedSubview(recordingTimerLabel)
        startRecordingButton.addConstrainedSubviews(startRecordingButtonInnerRedView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 38),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 38),

            recordingTimerLabelBackground.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            recordingTimerLabelBackground.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 10),
            recordingTimerLabelBackground.centerXAnchor.constraint(equalTo: centerXAnchor),

            recordingTimerLabel.topAnchor.constraint(equalTo: recordingTimerLabelBackground.topAnchor, constant: 7),
            recordingTimerLabel.bottomAnchor.constraint(equalTo: recordingTimerLabelBackground.bottomAnchor, constant: -7),
            recordingTimerLabel.leadingAnchor.constraint(equalTo: recordingTimerLabelBackground.leadingAnchor, constant: 15),
            recordingTimerLabel.trailingAnchor.constraint(equalTo: recordingTimerLabelBackground.trailingAnchor, constant: -15),

            switchCameraButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5),
            switchCameraButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 55),
            switchCameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            switchCameraButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 55),
            
            showVideoPickerButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5),
            showVideoPickerButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 55),
            showVideoPickerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            showVideoPickerButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 55),

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

    func configureVideoPreview() async {
        await viewModel.configureNewCaptureSession()
        videoPreview.videoPreviewLayer.session = viewModel.captureSession

        Task.detached { [weak self] in
            // Runtime error will be thrown if this isn't called from background thread
            await self?.viewModel.captureSession.startRunning()
        }
    }

    func startUpdatingRecordingTimerLabel() {
        viewModel.recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            
            // Make sure the label isn't updated if the user tries to record for over 5 minutes
            if viewModel.recordingTimerDurationAsInt > 300 {
                stopRecording()
            } else {
                self.recordingTimerLabel.text = "\(self.viewModel.recordingTimerDurationAsInt.secondsAsTimerDurationString) / 05:00"
            }
        }
    }

    @objc func startRecording() {
        startRecordingButton.removeGestureRecognizer(startRecordingTapGesture)
        startRecordingButton.addGestureRecognizer(stopRecordingTapGesture)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.startRecordingButtonInnerRedView.layer.cornerRadius = 8
            self?.startRecordingButtonInnerRedView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self?.switchCameraButton.alpha = 0
            self?.switchCameraButton.isEnabled = false
            self?.showVideoPickerButton.alpha = 0
            self?.showVideoPickerButton.isEnabled = false
            self?.backButton.alpha = 0
            self?.backButton.isEnabled = false
        }

        viewModel.startRecording()
        startUpdatingRecordingTimerLabel()
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
        delegate?.createVideoEntryViewControllerShouldDismiss()
    }

    @objc func switchCameraButtonTapped() {
        viewModel.switchCamera()
    }
    
    @objc func showVideoPickerButtonTapped() {
        delegate?.createVideoEntryViewControllerShouldPresentVideoPicker()
    }
}
