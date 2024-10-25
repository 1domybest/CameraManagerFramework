//
//  CameraController.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import AVFoundation

extension CameraManager {
    ///
    /// output 용 콜백등록
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func setAppendQueueCallback (appendQueueCallback: CameraManagerFrameWorkDelegate) {
        self.cameraManagerFrameWorkDelegate = appendQueueCallback
    }
    
    ///
    /// 카메라 프레임레이트 [fps] 지정함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func setFrameRate(desiredFrameRate: Double, for camera: AVCaptureDevice) {
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
        
        if let selectedFormat = bestFormat, let selectedFrameRateRange = bestFrameRateRange {
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
    
    ///
    /// 전/후 면 카메라 지정함수 [단일 스크린일경우만]
    ///
    /// - Parameters:
    ///     - position ( AVCaptureDevice ) : 카메라 방향
    /// - Returns:
    ///
    public func setPosition(_ position: AVCaptureDevice.Position) {
        DispatchQueue.main.async {
            self.position = position
            self.mainCameraPostion = position
            
            if self.isMultiCamSupported && self.cameraViewMode == .doubleScreen {
                self.setMirrorMode(isMirrorMode: position == .front)
            } else {
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
    
    ///
    /// 큰화면 작은화면 스위치
    ///
    /// - Parameters:
    ///     - position ( AVCaptureDevice ) : 카메라 방향
    /// - Returns:
    ///
    public func switchMainCamera (mainCameraPostion: AVCaptureDevice.Position) {
        self.mainCameraPostion = mainCameraPostion
    }
    
    ///
    /// 카메라 좌우반전 설정
    ///
    /// - Parameters:
    ///    - isMirrorMode ( Bool ) : 기본: 전면카메라 = true / 후면카메라 = false
    /// - Returns:
    ///
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
            self.mirrorCamera = isMirrorMode
            
            if self.position == .back {
                self.backCameraConnection?.isVideoMirrored = mirrorCamera
            } else {
                self.frontCameraConnection?.isVideoMirrored = mirrorCamera
            }
        }
        
    }
    
    ///
    /// 가로/세로 모드에 따른 비디오 방향설정 함수
    ///
    /// - Parameters:
    ///     - videoOrientation ( AVCaptureVideoOrientation ) : 기기방향
    /// - Returns:
    ///
    public func setVideoOrientation(_ videoOrientation: AVCaptureVideoOrientation) {
        self.videoOrientation = videoOrientation
        backCameraConnection?.videoOrientation = videoOrientation
    }
    
    ///
    /// 화면 줌했을시 카메라의 Zoom 을 해주는 함수
    ///
    /// - Parameters:
    ///    - scale ( CGFloat ) : 줌 정도
    /// - Returns:
    ///
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
    
    ///
    /// Zoom 세팅
    ///
    /// - Parameters:
    ///    - scale ( CGFloat ) : 줌 정도
    /// - Returns:
    ///
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
    
    ///
    /// 카메라 포커스 변경함수
    ///
    /// - Parameters:
    ///    - pointOfInterest ( CGPoint ) : 누른 화면좌표
    /// - Returns: Bool
    ///
    public func changeDeviceFocusPointOfInterest(to pointOfInterest: CGPoint) -> Bool {
        guard pointOfInterest.x <= 1, pointOfInterest.y <= 1, pointOfInterest.x >= 0,
              pointOfInterest.y >= 0
        else {
            return false
        }
        
        if let captureDevice = backCamera, captureDevice.isFocusModeSupported(.continuousAutoFocus),
           captureDevice.isFocusPointOfInterestSupported
        {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.focusPointOfInterest = pointOfInterest
                captureDevice.focusMode = .continuousAutoFocus
                captureDevice.unlockForConfiguration()
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    ///
    /// 카메라 노출조절 함수
    ///
    /// - Parameters:
    ///    - pointOfInterest ( CGPoint ) : 노출정도
    /// - Returns: Bool
    ///
    public func changeDeviceExposurePointOfInterest(to pointOfInterest: CGPoint) -> Bool {
        guard pointOfInterest.x <= 1, pointOfInterest.y <= 1, pointOfInterest.x >= 0, pointOfInterest.y >= 0,
              let captureDevice = backCamera,
              captureDevice.isExposureModeSupported(.continuousAutoExposure),
              captureDevice.isExposurePointOfInterestSupported
        else {
            return false
        }
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.exposurePointOfInterest = pointOfInterest
            captureDevice.exposureMode = .continuousAutoExposure
            captureDevice.unlockForConfiguration()
            return true
        } catch {
            return false
        }
    }
    
    ///
    ///  카메라 View모드 변경 [멀티, 싱글]
    ///
    /// - Parameters:
    ///    - onTorch ( Bool ) : 장치 켜짐 유무
    /// - Returns:
    ///
    public func setCameraViewMode (cameraViewMode: CameraViewMode) {
        if self.dualVideoSession?.isRunning ?? false {
            if cameraViewMode == .singleScreen {
                self.multiCameraView?.smallCameraView?.isHidden = true
            } else {
                self.multiCameraView?.smallCameraView?.isHidden = false
            }
        } else {
            self.setPosition(self.mainCameraPostion)
        }
        
        self.cameraViewMode = cameraViewMode
    }
    
    ///
    /// 기기 플레쉬 장치 on/off 함수
    ///
    /// - Parameters:
    ///    - onTorch ( Bool ) : 장치 켜짐 유무
    /// - Returns:
    ///
    public func toggleTorch(onTorch: Bool) {
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
    
    ///
    /// 기기 플레쉬 장치 on/off 함수
    ///
    /// - Parameters:
    ///    - onTorch ( Bool ) : 장치 켜짐 유무
    /// - Returns:
    ///
    public func doseHaseTorch() -> Bool {
        guard let device = backCamera, device.hasTorch else {
            return false
        }
        return true
    }
}
