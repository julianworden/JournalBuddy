//
//  UploadVideoEntryView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/23/23.
//

import Combine
import CoreMedia
import UIKit

class UploadVideoEntryView: UIView, MainView {
    private lazy var mainScrollView = UIScrollView()
    private lazy var mainScrollViewContentStack = UIStackView(
        arrangedSubviews: [
            videoPlayerView,
            underVideoPlayerStack
        ]
    )
    lazy var videoPlayerView = VideoPlayerView(videoPlayerURL: viewModel.recordedVideoURL)
    private lazy var underVideoPlayerStack = UIStackView(
        arrangedSubviews: [
            saveToDeviceToggleStack,
            saveToDeviceExplanationLabel,
            uploadButton,
            savingStack,
            uploadingStack
        ]
    )
    private lazy var saveToDeviceToggleStack = UIStackView(
        arrangedSubviews: [
            saveToDeviceLabel,
            saveToDeviceSwitch
        ]
    )
    private lazy var saveToDeviceLabel = UILabel()
    private lazy var saveToDeviceSwitch = UISwitch()
    private lazy var saveToDeviceExplanationLabel = UILabel()
    private lazy var uploadButton = PrimaryButton(title: "Upload")
    private lazy var savingStack = ProgressViewStack()
    private lazy var uploadingStack = ProgressViewStack()
    
    var viewModel: UploadVideoEntryViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UploadVideoEntryViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        configure()
        makeAccessible()
        subscribeToPublishers()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .background
        
        mainScrollView.showsVerticalScrollIndicator = false
        
        mainScrollViewContentStack.axis = .vertical
        mainScrollViewContentStack.spacing = UIConstants.mainStackViewSpacing
        mainScrollViewContentStack.layoutMargins = UIConstants.mainStackViewLeadingAndTrailingLayoutMargins
        mainScrollViewContentStack.isLayoutMarginsRelativeArrangement = true
        mainScrollViewContentStack.alignment = .center
        
        underVideoPlayerStack.axis = .vertical
        underVideoPlayerStack.spacing = 15
        
        if viewModel.videoWasSelectedFromLibrary {
            // Necessary because saveToDevice switch has an intrinsic content size, so just
            // not configuring it isn't enough to hide it
            saveToDeviceToggleStack.isHidden = true
        } else {
            configureSaveToDeviceToggleUI()
        }
        
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        
        savingStack.isHidden = true
        uploadingStack.isHidden = true
    }
    
    func makeAccessible() {
        saveToDeviceLabel.adjustsFontForContentSizeCategory = true
        saveToDeviceExplanationLabel.adjustsFontForContentSizeCategory = true
    }
    
    func subscribeToPublishers() {
        subscribeToViewStateUpdates()
        subscribeToVideoUploadingProgress()
    }
    
    func constrain() {
        addConstrainedSubviews(mainScrollView)
        mainScrollView.addConstrainedSubviews(mainScrollViewContentStack)
        
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            mainScrollViewContentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainScrollViewContentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainScrollViewContentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainScrollViewContentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),

            videoPlayerView.heightAnchor.constraint(equalToConstant: 480),
            videoPlayerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoPlayerView.widthAnchor.constraint(equalToConstant: 270),
            
            underVideoPlayerStack.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            underVideoPlayerStack.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            
            uploadButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 49),
        ])
    }
    
    func subscribeToViewStateUpdates() {
        viewModel.$viewState
            .sink { [weak self] viewState in
                guard let self else { return }
                
                switch viewState {
                case .videoEntryIsSavingToDevice:
                    self.configureSavingToDeviceProgressViewUI()
                    self.configureUploadingProgressViewUI()
                    self.presentSavingToDeviceUI()
                    self.presentUploadingUI()
                case .videoEntryWasSavedToDevice:
                    self.savingStack.updateProgress(to: 1.0)
                    self.savingStack.updateLabelText(to: "Saved.")
                    self.uploadingStack.updateLabelText(to: "Uploading...")
                case .videoEntryIsUploading:
                    // If video was saved to device, uploading UI was already configured
                    if !self.viewModel.saveVideoToDevice {
                        self.uploadingStack.updateLabelText(to: "Uploading...")
                        self.configureUploadingProgressViewUI()
                        self.presentUploadingUI()
                    }
                case .videoEntryWasUploaded:
                    self.uploadingStack.updateLabelText(to: "Uploaded.")
                    self.uploadingStack.hideActivityIndicator()
                case .error(_):
                    configureErrorUI()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToVideoUploadingProgress() {
        NotificationCenter.default.publisher(for: .videoIsUploading)
            .sink { [weak self] notification in
                guard let loadingProgress = notification.userInfo?[NotificationConstants.uploadingProgress] as? Double else {
                    return
                }
                
                self?.uploadingStack.updateProgress(to: Float(loadingProgress))

                
                if loadingProgress == 1.0 {
                    self?.uploadingStack.updateLabelText(to: "Finalizing...")
                    self?.uploadingStack.presentActivityIndicator()
                }
            }
            .store(in: &cancellables)
    }
    
    func configureSaveToDeviceToggleUI() {
        saveToDeviceToggleStack.distribution = .equalCentering
        saveToDeviceToggleStack.alignment = .center
        
        saveToDeviceLabel.text = "Save to Device"
        saveToDeviceLabel.font = UIFontMetrics.avenirNextRegularBody
        saveToDeviceLabel.textAlignment = .left
        saveToDeviceLabel.textColor = .primaryElement
        saveToDeviceLabel.numberOfLines = 2
        saveToDeviceLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        saveToDeviceSwitch.onTintColor = .primaryElement
        saveToDeviceSwitch.backgroundColor = .disabled
        saveToDeviceSwitch.layer.cornerRadius = 16
        saveToDeviceSwitch.thumbTintColor = .background
        saveToDeviceSwitch.clipsToBounds = true
        saveToDeviceSwitch.addTarget(self, action: #selector(saveToDeviceSwitchTapped), for: .valueChanged)
        
        let saveToDeviceExplanationLabelParagraphStyle = NSMutableParagraphStyle()
        saveToDeviceExplanationLabelParagraphStyle.lineSpacing = 5
        let saveToDeviceExplanationLabelText = NSMutableAttributedString(
            string: "We recommend saving your entry to your device in case something goes wrong during uploading."
        )
        saveToDeviceExplanationLabelText.addAttribute(
            .paragraphStyle,
            value: saveToDeviceExplanationLabelParagraphStyle,
            range: NSRange(location: 0, length: saveToDeviceExplanationLabelText.length)
        )
        saveToDeviceExplanationLabel.attributedText = saveToDeviceExplanationLabelText
        saveToDeviceExplanationLabel.font = UIFontMetrics.avenirNextRegularFootnote
        saveToDeviceExplanationLabel.textAlignment = .left
        saveToDeviceExplanationLabel.textColor = .primaryElement
        saveToDeviceExplanationLabel.numberOfLines = 0
    }
    
    func configureSavingToDeviceProgressViewUI() {
        videoPlayerView.disable()
        savingStack.updateLabelText(to: "Saving...")
        uploadingStack.updateLabelText(to: "Waiting...")
    }
    
    func configureUploadingProgressViewUI() {
        videoPlayerView.disable()
    }
    
    func configureErrorUI() {
        videoPlayerView.enable()
        saveToDeviceToggleStack.isHidden = false
        savingStack.isHidden = true
        uploadingStack.isHidden = true
        uploadButton.isHidden = false
        
        if !viewModel.videoWasSelectedFromLibrary {
            saveToDeviceToggleStack.isHidden = false
            saveToDeviceExplanationLabel.isHidden = false
        }
    }
    
    func presentUploadingUI() {
        uploadingStack.isHidden = false
        saveToDeviceToggleStack.isHidden = true
        saveToDeviceExplanationLabel.isHidden = true
        uploadButton.isHidden = true
    }
    
    func presentSavingToDeviceUI() {
        savingStack.isHidden = false
        saveToDeviceToggleStack.isHidden = true
        saveToDeviceExplanationLabel.isHidden = true
        uploadButton.isHidden = true
    }
    
    @objc func saveToDeviceSwitchTapped(_ sender: UISwitch) {
        viewModel.saveVideoToDevice = sender.isOn
    }
    
    @objc func uploadButtonTapped() {
        Task {
            videoPlayerView.pauseButtonTapped()
            await viewModel.uploadButtonTapped()
        }
    }
}
