//
//  CameraManagerFrameWorkDelegate.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 11/25/23.
//

import AVFoundation
import Foundation

///
/// `CameraManagerFrameWorkDelegate`
///
/// protocol for output frame from camera
@objc public protocol CameraManagerFrameWorkDelegate {
    
    ///
    /// videoCaptureOutput will call after rendering
    ///
    /// this call back will call after rendering ``SingleCameraView`` or ``MultiCameraView``
    ///
    /// but if you set ``CameraRenderingMode``  to ``CameraRenderingMode/offScreen`` will not call
    ///
    /// - Parameters:
    ///    - pixelBuffer: pixelBuffer from camera output
    ///    - time: time for buffer
    ///    - position: position of camera
    ///
    @objc optional func videoCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position)
    
    ///
    /// videoCaptureOutput will call after rendering
    ///
    /// this call back will call after rendering ``SingleCameraView`` or ``MultiCameraView``
    ///
    /// - Parameters:
    ///    - sampleBuffer: sampleBuffer from Camera
    ///    - position: position of camera
    ///
    @objc optional func videoCaptureOutput(sampleBuffer: CMSampleBuffer, position: AVCaptureDevice.Position)
    
    
    ///
    /// videoOffscreenRenderCaptureOutput will call before rendering
    ///
    /// this call back will call before rendering ``SingleCameraView`` or ``MultiCameraView``
    ///
    /// but if you set ``CameraRenderingMode`` to ``CameraRenderingMode/normal`` will not call
    ///
    /// - Parameters:
    ///    - pixelBuffer: pixelBuffer from camera output
    ///    - time: time for buffer
    ///    - position: position of camera
    ///
    @objc optional func videoOffscreenRenderCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position)
    
    ///
    /// videoOffscreenRenderCaptureOutput will call before rendering
    ///
    /// this call back will call before rendering ``SingleCameraView`` or ``MultiCameraView``
    ///
    /// but if you set ``CameraRenderingMode`` to ``CameraRenderingMode/normal`` will not call
    ///
    /// - Parameters:
    ///    - sampleBuffer: sampleBuffer from Camera
    ///    - position: position of camera
    ///
    @objc optional func videoOffscreenRenderCaptureOutput(CMSampleBuffer: CMSampleBuffer, position: AVCaptureDevice.Position)
    
    ///
    /// videoChangeAbleCaptureOutput for edit frame
    ///
    ///
    /// if you want to change sampleBuffer
    ///
    /// such as use own you filter kinda thing
    ///
    /// get Buffer from paramters and change
    ///
    /// and if you return buffer that you changed
    ///
    /// it will show on screen
    ///
    /// - Parameters:
    ///    - pixelBuffer: pixelBuffer from camera output
    ///    - time: time for buffer
    ///    - position: position of camera
    ///
    /// - Returns: buffer for render `CMSampleBuffer`
    ///
    @objc optional func videoChangeAbleCaptureOutput(
           pixelBuffer: CVPixelBuffer,
           time: CMTime,
           position: AVCaptureDevice.Position
       ) -> CVPixelBuffer?
    
    ///
    /// videoChangeAbleCaptureOutput for edit frame
    ///
    /// if you want to change sampleBuffer
    ///
    /// such as use own you filter kinda thing
    ///
    /// get Buffer from paramters and change
    ///
    /// and if you return buffer that you changed
    ///
    /// it will show on screen
    ///
    /// - Parameters:
    ///    - sampleBuffer: sampleBuffer from Camera
    ///    - position: position of camera
    ///
    /// - Returns: buffer for render `CMSampleBuffer`
    ///
    @objc optional func videoChangeAbleCaptureOutput(
        CMSampleBuffer: CMSampleBuffer,
        position: AVCaptureDevice.Position
    ) -> CMSampleBuffer?

}
