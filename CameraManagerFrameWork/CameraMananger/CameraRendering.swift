//
//  CameraRendering.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import UIKit
import AVFoundation

/// Rendering Functions For ``CameraManager``
extension CameraManager {
    
    /**
     Set Gesture Event For ``singleCameraView``
     */
    public func setupGestureRecognizers() {
        // 단일 카메라 뷰에 핀치 제스처 추가
        if cameraOptions?.enAblePinchZoom ?? false {
            let singleCameraPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(singleViewHandlePinchGesture(_:)))
            singleCameraView?.addGestureRecognizer(singleCameraPinchGesture)
        }
        
        
        if cameraOptions?.tapAutoFocusAndExposure ?? false {
            let singleCameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleCameraHandleTapGesture(_:)))
            singleCameraTapGesture.delegate = self // delegate 설정 (필요한 경우)
            singleCameraView?.addGestureRecognizer(singleCameraTapGesture)
        }
    }
    
    
    /**
     Set Pan Gesture Event For ``MultiCameraView`` And ``SmallCameraView``
     */
    public func setupPanGesture() {
        // 서브 카메라 뷰에 드래그 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(smallViewHandlePanGesture(_:)))
        panGesture.delegate = self
        multiCameraView?.isUserInteractionEnabled = true
        multiCameraView?.addGestureRecognizer(panGesture)
    }
    
    /**
     Set Grag Gesture Event For ``MultiCameraView`` And ``SmallCameraView``
     */
    @objc func smallViewHandlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        guard let view = gesture.view else { return }
        
        // 제스처 상태에 따라 위치 업데이트
        let translation = gesture.translation(in: view.superview)
        
        switch gesture.state {
        case .began, .changed:
            // 뷰의 새로운 위치 계산
            let newCenter = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            print("새로운 위치 \(newCenter.x) - \(newCenter.y)")
            view.center = newCenter
            // 제스처의 변화를 리셋
            gesture.setTranslation(.zero, in: view.superview)
        case .ended, .cancelled:
            // 드래그가 끝났을 때 추가 처리 (예: 진동 효과, 애니메이션 등)
            print("드래그 종료")
        default:
            break
        }
    }
    
    /**
     Set PinchZoom Gesture Event For ``singleCameraView``

     - Parameters:
        - gesture: gesture that you wnat to add
     */
    @objc func singleViewHandlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.view != nil else { return }
        if self.cameraOptions?.cameraSessionMode == .multiSession && self.position == .front { return }
        if gesture.state == .changed {

            let scale = Double(gesture.scale)
            
            var preZoomFactor: Double = .zero
            var zoomFactor: Double = .zero
            
            // 전면 또는 후면 카메라에 따라 줌 값 계산
            if position == .front {
                preZoomFactor = frontCameraCurrentZoomFactor * scale
                zoomFactor = min(max(preZoomFactor, self.frontCameraMinimumZoonFactor), self.frontCameraMaximumZoonFactor)
            } else {
                preZoomFactor = backCameraCurrentZoomFactor * scale
                zoomFactor = min(max(preZoomFactor, self.backCameraMinimumZoonFactor), self.backCameraMaximumZoonFactor)
            }
            
            // 줌 값 적용
            self.setZoom(position: position, zoomFactor: zoomFactor)
            
            // 스케일 값 초기화
            gesture.scale = 1.0
        }
    }
    
    /**
     Set Tab Gesture Event For ``singleCameraView``

     - Parameters:
        - gesture: gesture that you wnat to add
     */
    @objc private func singleCameraHandleTapGesture(_ gesture: UITapGestureRecognizer) {
        // 현재 탭 위치를 superview 좌표계에서 얻기
        let location = gesture.location(in: gesture.view)
        
        // 터치 좌표를 0~1 범위로 정규화 (카메라 노출용 좌표로 변환)
        if let view = gesture.view {
            let normalizedPoint = CGPoint(
                x: location.x / view.bounds.width,
                y: location.y / view.bounds.height
            )
            print("노출 조절 \(normalizedPoint)")
            // 노출, 포커스 조절 함수 호출
            let resultOfExposure:Bool = self.changeDeviceExposurePointOfInterest(to: normalizedPoint)
            let resultOfFocus:Bool = self.changeDeviceFocusPointOfInterest(to: normalizedPoint)
            
            if resultOfExposure || resultOfFocus {
                // 문양 포시
                if cameraOptions?.showTapAutoFocusAndExposureRoundedRectangle ?? false {
                    self.singleCameraView?.showFocusBorder(at: normalizedPoint)
                }
            }
            
        }
    }

    /**
     Convert UIView From UIView to UIImage for Thumbnail
     - Parameters:
        - view: UIView for use
     
     - Returns: `UIImage`
     */
    public func createUIImageFromUIView(from view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
      
    /**
     for ``CameraSessionMode/multiSession`` View rendering
     
     when after sampleBuffer came out from output
     
     - Parameters:
        - sampleBuffer: buffer
        - pixelBuffer: buffer from sampleBuffer
        - time: time from sampleBuffer
        - sourceDevicePosition: position of buffer
     */
    public func doubleScreenCameraModeRender (sampleBuffer: CMSampleBuffer?, pixelBuffer: CVPixelBuffer, time: CMTime, sourceDevicePosition: AVCaptureDevice.Position) {
          
          switch sourceDevicePosition {
          case .front:
              if self.mainCameraPostion == .front {
                  self.multiCameraView?.updateMainCameraBuffer(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, sourceDevicePosition: sourceDevicePosition)
              } else {
                  self.multiCameraView?.updateSmallCameraBuffer(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, sourceDevicePosition: sourceDevicePosition)
              }
          case .back:
              if self.mainCameraPostion == .back {
                  self.multiCameraView?.updateMainCameraBuffer(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, sourceDevicePosition: sourceDevicePosition)
              } else {
                  self.multiCameraView?.updateSmallCameraBuffer(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, sourceDevicePosition: sourceDevicePosition)
              }
          default:
              break
          }
      }
      
    /**
     for ``CameraSessionMode/singleSession`` View rendering
     
     when after sampleBuffer came out from output
     
     - Parameters:
        - sampleBuffer: buffer
        - pixelBuffer: buffer from sampleBuffer
        - time: time from sampleBuffer
        - sourceDevicePosition: position of buffer
     */
      public func singleCameraModeRender (sampleBuffer: CMSampleBuffer?, pixelBuffer: CVPixelBuffer, time: CMTime, sourceDevicePosition: AVCaptureDevice.Position) {
          
          switch sourceDevicePosition {
          case .front:
              if self.position == .front {
                  self.singleCameraView?.update(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, position: sourceDevicePosition)
              }
          case .back:
              if self.position == .back {
                  self.singleCameraView?.update(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, position: sourceDevicePosition)
              }
          default:
              self.singleCameraView?.update(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, position: sourceDevicePosition)
              print("기타 장치의 프레임입니다.")
          }
      }
}

extension CameraManager: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension CameraManager {
    
    /**
     renderingCameraFrame
     
     this function checking about what screen mode and what session you use
     
     and what delegate you use and
     
     decide where frame should go
    
     - Parameters:
        - sampleBuffer: CMSampleBuffer
        - connection: AVCaptureConnection
     
     */
    func renderingCameraFrame(
        sampleBuffer: CMSampleBuffer,
        connection: AVCaptureConnection
    ) {
        guard var pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
              return
          }
        guard let sourcePostion: AVCaptureDevice.Position = connection.inputPorts.first?.sourceDevicePosition else { return }
          // 타임스탬프 추출
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        
        self.previousImageBuffer = pixelBuffer
        self.previousTimeStamp = timestamp
        
        if self.cameraOptions?.cameraRenderingMode == .offScreen {
            
            if !self.isShowThumbnail {
                self.cameraManagerFrameWorkDelegate?.videoOffscreenRenderCaptureOutput?(pixelBuffer: pixelBuffer, time: timestamp, position: sourcePostion)
                self.cameraManagerFrameWorkDelegate?.videoOffscreenRenderCaptureOutput?(sampleBuffer: sampleBuffer, position: sourcePostion)
            }
        } else {
            
            let newPixelBuffer:CVPixelBuffer? = self.cameraManagerFrameWorkDelegate?.videoChangeAbleCaptureOutput?(pixelBuffer: pixelBuffer, time: timestamp, position: sourcePostion)
            
            let newCMSampleBuffer:CMSampleBuffer? = self.cameraManagerFrameWorkDelegate?.videoChangeAbleCaptureOutput?(CMSampleBuffer: sampleBuffer, position: sourcePostion)
            
            if let newPixelBuffer = newPixelBuffer {
                pixelBuffer = newPixelBuffer
            } else if let newCMSampleBuffer =  newCMSampleBuffer {
                if let newPixelBuffer = CMSampleBufferGetImageBuffer(newCMSampleBuffer) {
                    pixelBuffer = newPixelBuffer
                  }
            }
           
            if self.dualVideoSession?.isRunning ?? false {
                self.doubleScreenCameraModeRender(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
            } else {
                self.singleCameraModeRender(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
            }
        }
    }
    
    public func appendFrame(
        sampleBuffer: CMSampleBuffer,
        sourcePostion: AVCaptureDevice.Position
    ) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        if self.dualVideoSession?.isRunning ?? false {
            self.doubleScreenCameraModeRender(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
        } else {
            self.singleCameraModeRender(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
        }
    }
    
    public func appendFrame(
        pixelBuffer: CVPixelBuffer,
        sourcePostion: AVCaptureDevice.Position,
        timestamp: CMTime
    ) {
        if self.dualVideoSession?.isRunning ?? false {
            self.doubleScreenCameraModeRender(sampleBuffer: nil, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
        } else {
            self.singleCameraModeRender(sampleBuffer: nil, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
        }
    }
    
    
    /**
     renderingThumbnailFrame
     
     when you use thumbnail rendering
     
     and if you also want to full video and include thumbnail
     
     the thumbnail image will throw this function and you will get
     
     the buffer for thumbnail and time from delgate
    
     - Parameters:
        - sampleBuffer: CMSampleBuffer
        - connection: AVCaptureConnection
     */
    func renderingThumbnailFrame(
        pixelBuffer: CVPixelBuffer,
        sourcePostion: AVCaptureDevice.Position
    ) {
        self.previousImageBuffer = pixelBuffer
        let frameDuration = CMTimeMakeWithSeconds(1.0 / self.frameRate, preferredTimescale: 600) // 1/30초를 CMTime으로 변환 (600은 일반적인 timescale)
        
        if let previousTime = previousTimeStamp {
            previousTimeStamp = CMTimeAdd(previousTime, frameDuration) // 이전 시간에 프레임 시간을 추가
        } else {
            previousTimeStamp = frameDuration // 이전 시간이 없으면 그냥 1/30초로 초기화
        }
        
        // 타임스탬프 추출
        guard let timestamp = self.previousTimeStamp else { return }
    
        
        if self.dualVideoSession != nil {
            self.doubleScreenCameraModeRender(sampleBuffer: nil, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
        } else {
            self.singleCameraModeRender(sampleBuffer: nil, pixelBuffer: pixelBuffer, time: timestamp, sourceDevicePosition: sourcePostion)
        }
    }
}
