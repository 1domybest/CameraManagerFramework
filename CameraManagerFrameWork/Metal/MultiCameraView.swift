//
//  MultiCameraView.swift
//  AVFoundationMultiCameraWithSwiftUI
//
//  Created by 온석태 on 10/19/24.
//

import Foundation
import UIKit
import AVFoundation

/// ``MultiCameraView``
///
/// this view has two ``CameraMetalView`` ``MultiCameraView/smallCameraView`` and ``MultiCameraView/mainCameraView``
///
/// and this view only for ``CameraSessionMode/multiSession``
public class MultiCameraView: UIView, UIGestureRecognizerDelegate {
    // 부모 참조하기
    var parent: CameraManager?

    public var smallCameraView: CameraMetalView? // 서브 카메라뷰
    public var mainCameraView: CameraMetalView? // 서브 카메라뷰
    var cameraManagerFrameWorkDelegate:CameraManagerFrameWorkDelegate?
    init(parent: CameraManager, appendQueueCallback: CameraManagerFrameWorkDelegate) {
        super.init(frame: .zero)
        self.parent = parent
        self.cameraManagerFrameWorkDelegate = appendQueueCallback
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        print("MultiCameraView deinit")
    }
    
    public func unreference() {
        self.parent = nil
        self.cameraManagerFrameWorkDelegate = nil
        self.mainCameraView?.unreference()
        self.smallCameraView?.unreference()
        
        self.mainCameraView = nil
        self.smallCameraView = nil
    
    }

    private func setupView() {
        // 전체 화면을 차지하도록 설정
        self.backgroundColor = .clear // 필요에 따라 배경색 설정
        
        mainCameraView = CameraMetalView(cameraManagerFrameWorkDelegate: self)
        mainCameraView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: ((UIScreen.main.bounds.width) / 9)  * 16 )
        
        if let mainCameraView = mainCameraView {
            self.addSubview(mainCameraView)
        }
        
        // 메인 카메라 뷰에 핀치 제스처 추가
        if self.parent?.cameraOptions?.enAblePinchZoom ?? false {
            let mainCameraPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(multiViewHandlePinchGesture(_:)))
            mainCameraView?.addGestureRecognizer(mainCameraPinchGesture)
        }
        
        if self.parent?.cameraOptions?.tapAutoFocusAndExposure ?? false {
            let mainCameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(mainCameraHandleTapGesture(_:)))
            mainCameraTapGesture.delegate = self // delegate 설정 (필요한 경우)
            mainCameraView?.addGestureRecognizer(mainCameraTapGesture)
        }
        

        // 작은 카메라 뷰 설정
        smallCameraView = CameraMetalView(cameraManagerFrameWorkDelegate: self) // 원하는 크기로 설정
        smallCameraView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/4, height: ((UIScreen.main.bounds.width / 4) / 9)  * 16 )
        smallCameraView?.layer.cornerRadius = 5 // 원하는 반지름 크기로 설정
        smallCameraView?.clipsToBounds = true // 둥근 모서리의 효과가 나타나도록 설정
        
        if let smallCameraView = smallCameraView {
            self.addSubview(smallCameraView)
        }

        // 드래그 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        smallCameraView?.addGestureRecognizer(panGesture)
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delegate = self // delegate 설정 (필요한 경우)
        smallCameraView?.addGestureRecognizer(tapGesture)
    }
    
    @objc private func mainCameraHandleTapGesture(_ gesture: UITapGestureRecognizer) {
        // 현재 탭 위치를 superview 좌표계에서 얻기
        let location = gesture.location(in: gesture.view)
        
        // 터치 좌표를 0~1 범위로 정규화 (카메라 노출용 좌표로 변환)
        if let view = gesture.view {
            let normalizedPoint = CGPoint(
                x: location.x / view.bounds.width,
                y: location.y / view.bounds.height
            )
            print("노출 조절 \(normalizedPoint)")
            // 노출 조절 함수 호출

            let resultOfExposure:Bool = (self.parent?.changeDeviceExposurePointOfInterest(to: normalizedPoint) ?? false)
            let resultOfFocus:Bool = (self.parent?.changeDeviceFocusPointOfInterest(to: normalizedPoint) ?? false)
            
            if resultOfExposure || resultOfFocus {
                // 문양 포시
                if self.parent?.cameraOptions?.showTapAutoFocusAndExposureRoundedRectangle ?? false {
                    self.mainCameraView?.showFocusBorder(at: normalizedPoint)
                }
                
            }
        }
    }


    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        print("smallCameraView 탭됨")
        // 탭 제스처 처리 로직을 여기에 추가
        guard let parent = self.parent else { return }
        let postion:AVCaptureDevice.Position = parent.mainCameraPostion == .front ? .back : .front
        parent.setMainCameraPostion(mainCameraPostion: postion)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = self.smallCameraView else { return }
        
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began, .changed:
            let newCenter = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            
            // 뷰가 부모 뷰의 경계를 넘어가지 않도록 제한
            let halfWidth = view.bounds.width / 2
            let halfHeight = view.bounds.height / 2
            
            let minX = halfWidth
            let maxX = self.bounds.width - halfWidth
            let minY = halfHeight
            let maxY = self.bounds.height - halfHeight
            
            view.center = CGPoint(
                x: min(max(newCenter.x, minX), maxX),
                y: min(max(newCenter.y, minY), maxY)
            )
            
            // 제스처의 변화를 리셋
            gesture.setTranslation(.zero, in: self)
            
        case .ended, .cancelled:
            print("드래그 종료")
        default:
            break
        }
    }
    
    @objc func multiViewHandlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let parent = self.parent else { return }
        guard gesture.view != nil else { return }
//        if parent.mainCameraPostion == .front { return }
        print("줌 제스처")
        if gesture.state == .changed {
            let scale = Double(gesture.scale)

            var preZoomFactor: Double = .zero
            var zoomFactor: Double = .zero
            
            // 전면 또는 후면 카메라에 따라 줌 값 계산
            if parent.mainCameraPostion == .front {
                preZoomFactor = parent.frontCameraCurrentZoomFactor * scale
                zoomFactor = min(max(preZoomFactor, parent.frontCameraMinimumZoonFactor), parent.frontCameraMaximumZoonFactor)
            } else {
                preZoomFactor = parent.backCameraCurrentZoomFactor * scale
                zoomFactor = min(max(preZoomFactor, parent.backCameraMinimumZoonFactor), parent.backCameraMaximumZoonFactor)
            }
            
            // 줌 값 적용
            parent.setZoom(position: parent.mainCameraPostion, zoomFactor: zoomFactor)
            
            // 스케일 값 초기화
            gesture.scale = 1.0
        }
    }
    
    
    public func updateSmallCameraBuffer(sampleBuffer: CMSampleBuffer?, pixelBuffer: CVPixelBuffer, time: CMTime, sourceDevicePosition: AVCaptureDevice.Position) {
        self.smallCameraView?.update(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, position: sourceDevicePosition)
    }
    
    public func updateMainCameraBuffer(sampleBuffer: CMSampleBuffer?, pixelBuffer: CVPixelBuffer, time: CMTime, sourceDevicePosition: AVCaptureDevice.Position) {
        self.mainCameraView?.update(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer, time: time, position: sourceDevicePosition)
    }
    
    // Gesture Recognizer Delegate Method
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 두 제스처 인식기가 동시에 인식될 수 있도록 허용
        return true
    }
}

extension MultiCameraView: CameraManagerFrameWorkDelegate {
    public func videoCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position) {
        self.cameraManagerFrameWorkDelegate?.videoCaptureOutput?(pixelBuffer: pixelBuffer, time: time, position: position)
    }
    
    public func videoCaptureOutput(sampleBuffer: CMSampleBuffer, position: AVCaptureDevice.Position) {
        self.cameraManagerFrameWorkDelegate?.videoCaptureOutput?(sampleBuffer: sampleBuffer, position: position)
    }
    
    public func appendAudioQueue(sampleBuffer: CMSampleBuffer) {

    }
}
