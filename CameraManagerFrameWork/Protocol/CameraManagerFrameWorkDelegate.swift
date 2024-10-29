//
//  CameraManagerFrameWorkDelegate.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 11/25/23.
//

import AVFoundation
import Foundation

///
/// CameraManagerFrameWorkDelegate
@objc public protocol CameraManagerFrameWorkDelegate {
    ///
    /// videoCaptureOutput
    ///
    /// this call back will called after rendering `singleCameraView or multiCameraView`
    ///
    /// but if you set `CameraRenderingMode` to `.offScreen` will not called
    ///
    /// - Parameters:
    ///    - pixelBuffer: pixelBuffer from camera output
    ///    - time: time for buffer
    ///    - position: position of camera
    ///
    @objc optional func videoCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position)
    
    ///
    /// videoCaptureOutput
    ///
    /// this call back will called after rendering `singleCameraView or multiCameraView`
    ///
    /// - Parameters:
    ///    - sampleBuffer: sampleBuffer from Camera
    ///    - position: position of camera
    ///
    @objc optional func videoCaptureOutput(sampleBuffer: CMSampleBuffer, position: AVCaptureDevice.Position)
    
    
    ///
    /// videoOffscreenRenderCaptureOutput
    ///
    /// this call back will called before rendering `singleCameraView or multiCameraView`
    ///
    /// but if you set `CameraRenderingMode` to `.normal` will not called
    ///
    /// - Parameters:
    ///    - pixelBuffer: pixelBuffer from camera output
    ///    - time: time for buffer
    ///    - position: position of camera
    ///
    @objc optional func videoOffscreenRenderCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position)
    
    ///
    /// videoOffscreenRenderCaptureOutput
    ///
    /// this call back will called before rendering `singleCameraView or multiCameraView`
    ///
    /// but if you set `CameraRenderingMode` to `.normal` will not called
    ///
    /// - Parameters:
    ///    - sampleBuffer: sampleBuffer from Camera
    ///    - position: position of camera
    ///
    @objc optional func videoOffscreenRenderCaptureOutput(CMSampleBuffer: CMSampleBuffer, position: AVCaptureDevice.Position)
    
    ///
    /// videoChangeAbleCaptureOutput
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
    /// videoChangeAbleCaptureOutput
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
