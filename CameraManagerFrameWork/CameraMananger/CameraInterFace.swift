//
//  CameraInterFace.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import AVFoundation
import UIKit

/// Interface For CameraManager
extension CameraManager {
    
    /**
     Sets the thumbnail image.

     - Parameters:
       - image: The image to be set as the thumbnail.
     */
    public func setThumbnail(image: UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }
        self.thumbnail = cgImage
    }
    
    /**
     Sets Camera Output Delegate

     - Parameters:
       - appendQueueCallback: delegate
     */
    public func setAppendQueueCallback (appendQueueCallback: CameraManagerFrameWorkDelegate) {
        self.cameraManagerFrameWorkDelegate = appendQueueCallback
    }
    
    /**
     Sets Camera FrameRate

     - Parameters:
       - desiredFrameRate: frame rate you want
       - camera: camera Device
     */
    func setFrameRate(desiredFrameRate: Double, for camera: AVCaptureDevice) {
        var bestFormat: AVCaptureDevice.Format?
        var bestFrameRateRange: AVFrameRateRange?
        
        for format in camera.formats {
              for range in format.videoSupportedFrameRateRanges {
                  // Check if the format supports desired resolution and frame rate
                  let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                  if dimensions.width == Int32(1280) && dimensions.height == Int32(720) &&
                     range.maxFrameRate >= desiredFrameRate && range.minFrameRate <= desiredFrameRate {
                      if bestFormat == nil || range.minFrameRate < bestFrameRateRange?.minFrameRate ?? Double.greatestFiniteMagnitude {
                          bestFormat = format
                          bestFrameRateRange = range
                      }
                  }
              }
          }
        
        if let selectedFormat = bestFormat, let _ = bestFrameRateRange {
            do {
                try camera.lockForConfiguration()
                
                // 포맷 설정
                camera.activeFormat = selectedFormat
                
                // 프레임 레이트 설정
                camera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFrameRate))
                camera.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFrameRate))
                
                camera.unlockForConfiguration()
                
                print("Successfully set frame rate to \(desiredFrameRate) fps for \(camera.position.rawValue) camera.")
            } catch {
                print("Failed to set frame rate for \(camera.position.rawValue) camera: \(error.localizedDescription)")
            }
        } else {
            print("Desired frame rate \(desiredFrameRate) fps is not supported for \(camera.position.rawValue) camera.")
        }
    }
    
    /**
     Sets Camera Postion

     - Parameters:
       - position: camera postion

     */
    public func setPosition(_ position: AVCaptureDevice.Position) {
        DispatchQueue.main.async {
            self.position = position
            self.mainCameraPostion = position
            self.setMainCameraPostion(mainCameraPostion: self.mainCameraPostion)
            
            if self.isMultiCamSupported && self.cameraOptions?.cameraScreenMode == .doubleScreen {
                self.setMirrorMode(isMirrorMode: position == .front)
            } else {
                self.sessionQueue?.async {
                    if position == .back {
                        self.frontCaptureSession?.stopRunning()
                        self.backCaptureSession?.startRunning()
                        self.setZoom(position: .back, zoomFactor: self.backCameraDefaultZoomFactor)
                        self.setMirrorMode(isMirrorMode: false)
                    } else {
                        self.backCaptureSession?.stopRunning()
                        self.frontCaptureSession?.startRunning()
                        self.setZoom(position: .front, zoomFactor: self.frontCameraCurrentZoomFactor)
                        self.setMirrorMode(isMirrorMode: true)
                    }
                }
            }
        }
    }
    
    /**
     Sets Main Camera Postion

     this is only work when you use ``CameraSessionMode/multiSession`` from ``CameraSessionMode`` and ``CameraScreenMode/doubleScreen`` from ``CameraScreenMode``
     
     - Parameters:
       - mainCameraPostion: camera postion

     */
    public func setMainCameraPostion (mainCameraPostion: AVCaptureDevice.Position) {
        self.mainCameraPostion = mainCameraPostion
        self.cameraOptions?.onChangeMainScreenPostion?(self.mainCameraPostion)
    }
    
    /**
     Sets Camera Mirror Mode
     
     - Parameters:
       - isMirrorMode: mirror mode

     */
    public func setMirrorMode (isMirrorMode: Bool) {
        
        if self.dualVideoSession?.isRunning ?? false {
            if self.mainCameraPostion == .back {
                self.mirrorBackCamera = isMirrorMode
                self.multiBackCameraConnection?.isVideoMirrored = self.mirrorBackCamera
            } else {
                self.mirrorFrontCamera = isMirrorMode
                self.multiFrontCameraConnection?.isVideoMirrored = self.mirrorFrontCamera
            }
        } else {
            if self.position == .back {
                self.mirrorBackCamera = isMirrorMode
                self.backCameraConnection?.isVideoMirrored = self.mirrorBackCamera
            } else {
                self.mirrorFrontCamera = isMirrorMode
                self.frontCameraConnection?.isVideoMirrored = self.mirrorFrontCamera
            }
        }
        
    }
    
    /**
     Sets Camera Orientation
     
     - Parameters:
       - videoOrientation: Orientation

     */
    func setVideoOrientation(_ videoOrientation: AVCaptureVideoOrientation) {
        self.videoOrientation = videoOrientation
        backCameraConnection?.videoOrientation = videoOrientation
    }
    
    /**
     Sets Camera Zoom scale for Pinch Gesture
     
     - Parameters:
       - scale: scale of zoom

     */
    @objc
    public func handlePinchCamera(_ scale: CGFloat) {
        let currentPostion = self.isMultiCamSupported ? self.mainCameraPostion : self.position
        
        var preZoomFactor:Double = .zero
        var zoomFactor:Double = .zero
        
        if self.position == .front {
            preZoomFactor = frontCameraCurrentZoomFactor * scale
            zoomFactor = min(max(preZoomFactor, self.frontCameraMinimumZoonFactor), self.frontCameraMaximumZoonFactor)
        } else {
            preZoomFactor = backCameraCurrentZoomFactor * scale
            zoomFactor = min(max(preZoomFactor, self.backCameraMinimumZoonFactor), self.backCameraMaximumZoonFactor)
        }
        
        self.setZoom(position: currentPostion, zoomFactor: zoomFactor)
    }
    
    /**
     Sets Camera Zoom scale by CGFloat
     
     - Parameters:
       - position: postion of camera
       - zoomFactor: zoomFactor of camera
     */
    public func setZoom(position: AVCaptureDevice.Position, zoomFactor: CGFloat) {
        if let device = position == .front ? self.frontCamera : self.backCamera {

            if position == .front {
                self.frontCameraCurrentZoomFactor = zoomFactor
            } else {
                self.backCameraCurrentZoomFactor = zoomFactor
            }
            
            do {
                try device.lockForConfiguration()
                print("적용된 스케일\(zoomFactor)")
                device.videoZoomFactor = zoomFactor
            } catch {
                return
            }
            
            device.unlockForConfiguration()
        }
    }
    
    /**
     Sets Camera Auto Focus postion from device screen
     
     ** only back camera has this function **
     
     - Parameters:
       - pointOfInterest: point of screen

     - Returns: A Bool Value return if it's "false" mean is failed focus
     */
    public func changeDeviceFocusPointOfInterest(to pointOfInterest: CGPoint) -> Bool {
        guard pointOfInterest.x <= 1, pointOfInterest.y <= 1, pointOfInterest.x >= 0,
              pointOfInterest.y >= 0
        else {
            return false
        }
        
        guard pointOfInterest.x <= 1, pointOfInterest.y <= 1, pointOfInterest.x >= 0, pointOfInterest.y >= 0
        else {
            return false
        }
        
        var device = backCamera
        
        if self.mainCameraPostion == .front || self.position == .front {
            device = frontCamera
        }
        
        guard let captureDevice = device, captureDevice.isFocusPointOfInterestSupported else {
            return false
        } 
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.focusPointOfInterest = pointOfInterest
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.unlockForConfiguration()
            return true
        } catch {
            print("Error locking configuration: \(error)")
            return false
        }
    }
    
    /**
     Sets Camera UV Auto Exposure postion from device screen
     
     - Parameters:
       - pointOfInterest: point of screen

     - Returns: A Bool Value return if it's "false" mean is failed set exposure
     */
    public func changeDeviceExposurePointOfInterest(to pointOfInterest: CGPoint) -> Bool {
        guard pointOfInterest.x <= 1, pointOfInterest.y <= 1, pointOfInterest.x >= 0, pointOfInterest.y >= 0
        else {
            return false
        }
        
        var device = backCamera
        
        if self.mainCameraPostion == .front || self.position == .front {
            device = frontCamera
        }
        
        guard let captureDevice = device, captureDevice.isExposurePointOfInterestSupported else {
            return false
        }
        
        do {
            try captureDevice.lockForConfiguration()
            
            // 지원되는 노출 모드를 확인하여 설정
            if captureDevice.isExposureModeSupported(.autoExpose) {
                captureDevice.exposureMode = .autoExpose
            } else if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
                captureDevice.exposureMode = .continuousAutoExposure
            } else {
                return false // 노출 모드가 지원되지 않음
            }
            
            captureDevice.exposurePointOfInterest = pointOfInterest
            captureDevice.unlockForConfiguration()
            return true
        } catch {
            return false
        }
    }
    
    /**
     Sets Camera UV Exposure amount by float
     
     - Parameters:
       - bias: amount of UV Exposure
     */
    public func changeExposureBias(to bias: Float) {
        
        var device = backCamera
        
        if self.mainCameraPostion == .front || self.position == .front {
            device = frontCamera
        }
        
        guard let captureDevice = device, captureDevice.isExposureModeSupported(.continuousAutoExposure) else { return }
        
        
        do {
            try captureDevice.lockForConfiguration()
            
            // 노출 모드를 자동으로 설정하고 보정값을 조절
            captureDevice.exposureMode = .continuousAutoExposure
            captureDevice.setExposureTargetBias(bias) { (time) in
                print("노출 보정 적용 시간: \(time.seconds)초")
            }
            
            captureDevice.unlockForConfiguration()
            return
        } catch {
            return
        }
    }
    
    /**
     Sets Camera ScreenMode
     
     - Parameters:
       - cameraScreenMode: CameraScreenMode [.singleScreen, .doubleScreen]

     */
    public func setCameraScreenMode (cameraScreenMode: CameraScreenMode) {
        if self.dualVideoSession?.isRunning ?? false {
            if cameraScreenMode == .singleScreen {
                self.multiCameraView?.smallCameraView?.isHidden = true
            } else {
                self.multiCameraView?.smallCameraView?.isHidden = false
            }
        }
        self.cameraOptions?.cameraScreenMode = cameraScreenMode
        self.cameraOptions?.onChangeScreenMode?(self.cameraOptions?.cameraScreenMode)
    }
    
    /**
     Sets Torch
     
     if you use ".singleSession" you can turn on Torch
     
     when camera postio is ".back"
     
     - Parameters:
       - onTorch: TRUE = TorchOn | FALSE = TorchOff

     */
    public func setTorch(onTorch: Bool) {
        guard let device = backCamera, device.hasTorch else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = onTorch ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error toggling torch: \(error)")
        }
    }
    
    /**
     Check Device has Torch
     
     - Parameters:

     - Returns: A Bool Value return if it's "false" mean the device has no torch or broken
     */
    public func doseHaseTorch() -> Bool {
        guard let device = backCamera, device.hasTorch else {
            return false
        }
        return true
    }
}
