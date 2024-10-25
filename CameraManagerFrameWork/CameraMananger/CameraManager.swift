//
//  CameraManager.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import AVFoundation
import UIKit


public class CameraManager: NSObject {
    
    public var singleCameraView: CameraMetalView? // 단일 카메라뷰
    
    public var multiCameraView: MultiCameraView? // 멀티 카메라뷰
        
    public var cameraOptions: CameraOptions?
    
    public var cameraManagerFrameWorkDelegate: CameraManagerFrameWorkDelegate? // 렌더링후 실행하는 콜백
    
    public var previousImageBuffer: CVPixelBuffer? // 이전 프레임 이미지 버퍼
    public var previousTimeStamp: CMTime? // 이전 프레임 시간
    
    public var isMultiCamSupported: Bool = false // 다중 카메라 지원 유무
    public var isUltraWideCamera: Bool = true // 울트라 와이드 == 후면카메라 3개인지 0.5줌 가능유무
    
    // 카메라
    public var backCamera: AVCaptureDevice? // 후면카메라 [공통]
    public var frontCamera: AVCaptureDevice? // 전면 카메라 [공통]
    
    // 멀티세션 디바이스 세션 변수
    public var dualVideoSession:AVCaptureSession? // 멀티 카메라 세션
    
    public var multiCameraCaptureInput: AVCaptureDeviceInput? // 멀티 카메라 캡처 인풋
    
    
    public var multiBackCameraConnection: AVCaptureConnection? // 멀티 후면 카메라 커넥션
    public var multiFrontCameraConnection: AVCaptureConnection? // 멀티 전면 카메라 커넥션
    
    public var multiBackCameraCaptureInput: AVCaptureDeviceInput? // 멀티 후면 카메라 인풋
    public var multiFrontCameraCaptureInput: AVCaptureDeviceInput? // 멀티 전면 카메라 인풋
    
    public var multiBackCameravideoOutput: AVCaptureVideoDataOutput? // 후면 카메라 아웃풋
    public var multiFrontCameravideoOutput: AVCaptureVideoDataOutput? // 전면 카메라 아웃풋
    
    
    // 단일 디바이스 세션 변수
    public var backCaptureSession: AVCaptureSession? // 후면 카메라 세션
    public var frontCaptureSession: AVCaptureSession? // 전면 카메라 세션
    
    public var backCameraConnection: AVCaptureConnection? // 후면 카메라 커넥션
    public var frontCameraConnection: AVCaptureConnection? // 전면 카메라 커넥션
    
    public var backCameraCaptureInput: AVCaptureDeviceInput? // 후면 카메라 인풋
    public var frontCameraCaptureInput: AVCaptureDeviceInput? // 전면 카메라 인풋
    
    public var backCameravideoOutput: AVCaptureVideoDataOutput? // 후면 카메라 아웃풋
    public var frontCameravideoOutput: AVCaptureVideoDataOutput? // 전면 카메라 아웃풋
    
    // 멀티 디바이스 상태 변수
    public var mainCameraPostion: AVCaptureDevice.Position = .back // 카메라 포지션
    
    // 더블 스크린 관련변수
    public var mirrorBackCamera = false // 미러모드 유무
    public var mirrorFrontCamera = true // 미러모드 유무
    
    // 단일 디바이스 상태 변수
    public var position: AVCaptureDevice.Position = .back // 카메라 포지션
    
    public var preset: AVCaptureSession.Preset = .hd1280x720 // 화면 비율
    public var videoOrientation: AVCaptureVideoOrientation = .portrait // 카메라 가로 세로 모드
    public var mirrorCamera = true // 미러모드 유무
    
    // 큐
    public var sessionQueue: DispatchQueue? // 세션 큐
    public var videoDataOutputQueue: DispatchQueue? // 아웃풋 큐
    
    // 권한
    public var hasCameraPermission = false // 카메라 권한 유무
    
    
    // 줌관련 변수
    public var backCameraCurrentZoomFactor: CGFloat = 1.0
    public var backCameraDefaultZoomFactor: CGFloat = 1.0
    public var backCameraMinimumZoonFactor: CGFloat = 1.0
    public var backCameraMaximumZoonFactor: CGFloat = 1.0
    
    public var frontCameraCurrentZoomFactor: CGFloat = 1.0
    public var frontCameraDefaultZoomFactor: CGFloat = 1.0
    public var frontCameraMinimumZoonFactor: CGFloat = 1.0
    public var frontCameraMaximumZoonFactor: CGFloat = 1.0
    
    
    public var frameRate:Double = 30.0 // 초당 프레임
    public var maximumFrameRate:Double = 30.0 // 초당 프레임
    
    public var thumbnail: CGImage? // 썸네일
    
    public var displayLink: CADisplayLink? // 카메라 종료시 반복문으로 돌릴 링크
    
    public init(cameraOptions: CameraOptions) {
        self.cameraOptions = cameraOptions
        
        self.isMultiCamSupported = AVCaptureMultiCamSession.isMultiCamSupported
        
        
        self.position = cameraOptions.startPostion
        self.mainCameraPostion = cameraOptions.startPostion
        
        if cameraOptions.cameraSessionMode == .singleSession || !self.isMultiCamSupported {
            self.cameraOptions?.cameraScreenMode = .singleScreen
        }
        
        super.init()
        
        
        let attr = DispatchQueue.Attributes()
        sessionQueue = DispatchQueue(label: "camera.single.sessionqueue", attributes: attr)
        videoDataOutputQueue = DispatchQueue(label: "camera.single.videoDataOutputQueue")
        
        if self.cameraOptions?.cameraSessionMode == .multiSession {
            self.multiCameraView = MultiCameraView(parent: self, appendQueueCallback: self)
            self.setupMultiCaptureSessions()
            if self.cameraOptions?.cameraScreenMode == .singleScreen {
                self.multiCameraView?.smallCameraView?.isHidden = true
            }
        } else {
            self.singleCameraView = CameraMetalView(cameraManagerFrameWorkDelegate: self)
            self.maximumFrameRate = 60.0
            self.setupCaptureSessions()
            self.setupGestureRecognizers()
        }
        
    }
    
    ///
    /// 카메라 deit 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    deinit {
        print("CamerManager deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    ///
    /// 참조 해제
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func unreference() {
        self.cameraManagerFrameWorkDelegate = nil
        
        self.multiCameraView?.unreference()
        self.multiCameraView = nil
        self.singleCameraView?.unreference()
        self.singleCameraView = nil
        
        self.sessionQueue = nil
        self.videoDataOutputQueue = nil
        self.cameraManagerFrameWorkDelegate = nil
        self.cameraOptions = nil
        self.thumbnail = nil
        
        self.stopCamera()
        
        self.dualVideoSession = nil
        
        self.backCaptureSession = nil
        self.backCameraConnection = nil
        self.backCameraCaptureInput = nil
        self.backCameravideoOutput = nil
        
        self.frontCaptureSession = nil
        self.frontCameraConnection = nil
        self.frontCameraCaptureInput = nil
        self.frontCameravideoOutput = nil
        
        self.multiFrontCameraConnection = nil
        self.multiBackCameraConnection = nil
        self.multiBackCameraCaptureInput = nil
        self.multiBackCameravideoOutput = nil
        self.multiFrontCameravideoOutput = nil
        
        self.backCamera = nil
        self.frontCamera = nil
        
    }

    
    ///
    /// 카메라 퍼미션 체크 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func checkCameraPermission() {
        let mediaType = AVMediaType.video
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            hasCameraPermission = true
            
        case .notDetermined:
            sessionQueue?.suspend()
            AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
                guard let self = self else { return }
                self.hasCameraPermission = granted
                self.sessionQueue?.resume()
            }
            
        case .denied:
            hasCameraPermission = false
            
        default:
            break
        }
    }

    
}





