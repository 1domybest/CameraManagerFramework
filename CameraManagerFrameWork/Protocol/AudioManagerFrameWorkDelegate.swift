//
//  AameraManagerFrameWorkDelegate.swift
//  CameraManagerExample
//
//  Created by 온석태 on 11/4/24.
//

import Foundation
import AVFoundation


@objc public protocol AudioManagerFrameWorkDelegate {
    
    ///
    /// audioCaptureOutput
    ///
    /// - Parameters:
    ///    - sampleBuffer: sampleBuffer from audio output
    ///
    @objc optional func audioCaptureOutput(sampleBuffer: CMSampleBuffer)
}
