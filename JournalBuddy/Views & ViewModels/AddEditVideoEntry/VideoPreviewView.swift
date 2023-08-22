//
//  VideoPreviewView.swift
//  JournalBuddy
//
//  Created by Julian Worden on 8/22/23.
//

import AVFoundation
import UIKit

class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
