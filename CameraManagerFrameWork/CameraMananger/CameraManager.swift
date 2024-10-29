//
//  CameraManager.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import AVFoundation
import UIKit

/// Main Class For CameraManager
public class CameraManager: NSObject {
    
    /**
     CameraMetalView
     
     if you use this view make sure you using "singleSession" from CameraOptions
     
     # Code
         var cameraOptions:CameraOptions = CameraOptions()
         cameraOptions.cameraSessionMode = .singleSession
     */
    public var singleCameraView: CameraMetalView?
    
    /**
     MultiCameraView
     
    if you use this view make sure you using "multiSession" from CameraOptions
     
     # Code
         var cameraOptions:CameraOptions = CameraOptions()
         cameraOptions.cameraSessionMode = .multiSession
     */
    public var multiCameraView: MultiCameraView?
        
    /**
     Camera Setting Options
    
     this is  options for Camera
    
     # Code
         var cameraOptions:CameraOptions = CameraOptions()
         CameraManager(cameraOptions: cameraOptions)
     */
    public var cameraOptions: CameraOptions?
    
    /**
     CameraManagerFrameWorkDelegate
    
     this is observer from camera output
     */
    public var cameraManagerFrameWorkDelegate: CameraManagerFrameWorkDelegate?
    
    /**
     CVPixelBuffer
    
     this is last frame PixelBuffer from camera output
    
     */
    public var previousImageBuffer: CVPixelBuffer?
    
    /**
     CMTime
    
     this is last frame timeStamp from camera output
     
     */
    public var previousTimeStamp: CMTime?
    
    /**
     Bool
    
     if this value is true mean that the device that you use supported AVCaptureMultiCamSession
     
     so you can use ".multiSession" From CameraSessionMode
     
     */
    public var isMultiCamSupported: Bool = false
    
    /**
     Bool
    
     if this value is true mean that the device that you use has isUltraWideCamera so you can zoom 0.5
     
     */
    public var isUltraWideCamera: Bool = true
    
    /**
     AVCaptureDevice
    
     backCamera device
     */
    public var backCamera: AVCaptureDevice?
    
    /**
     AVCaptureDevice
    
     frontCamera device
     */
    public var frontCamera: AVCaptureDevice?
    
    
    // 멀티세션 디바이스 세션 변수
    
    /**
     AVCaptureMultiCamSession
    
     MultiCamSession is will be used when you setting ".multiSession" from CameraOptions
     */
    public var dualVideoSession:AVCaptureMultiCamSession?
    
    /**
     AVCaptureConnection
    
     BackCameraConnection for AVCaptureMultiCamSession
     */
    public var multiBackCameraConnection: AVCaptureConnection?
    
    /**
     AVCaptureConnection
    
     FrontCameraConnection for AVCaptureMultiCamSession
     */
    public var multiFrontCameraConnection: AVCaptureConnection?
    
    /**
     AVCaptureDeviceInput
    
     BackDeviceInput for AVCaptureMultiCamSession
     */
    public var multiBackCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     AVCaptureDeviceInput
    
     FrontDeviceInput for AVCaptureMultiCamSession
     */
    public var multiFrontCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     AVCaptureVideoDataOutput
    
     BackDeviceOutput for AVCaptureMultiCamSession
     */
    public var multiBackCameravideoOutput: AVCaptureVideoDataOutput?
    
    
    /**
     AVCaptureVideoDataOutput
    
     FrontDeviceOutput for AVCaptureMultiCamSession
     */
    public var multiFrontCameravideoOutput: AVCaptureVideoDataOutput?
    
    
    // 단일 디바이스 세션 변수
    
    /**
     AVCaptureSession
    
     backCaptureSession will be used when you setting ".singleSession" from CameraOptions
     */
    public var backCaptureSession: AVCaptureSession?
    
    /**
     AVCaptureSession
    
     frontCaptureSession will be used when you setting ".singleSession" from CameraOptions
     */
    public var frontCaptureSession: AVCaptureSession?
    
    /**
     AVCaptureConnection
    
     backCameraConnection for AVCaptureSession
     */
    public var backCameraConnection: AVCaptureConnection?
    
    /**
     AVCaptureConnection
    
     frontCameraConnection for AVCaptureSession
     */
    public var frontCameraConnection: AVCaptureConnection?
    
    /**
     AVCaptureDeviceInput
    
     backCameraCaptureInput for AVCaptureSession
     */
    public var backCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     AVCaptureDeviceInput
    
     frontCameraCaptureInput for AVCaptureSession
     */
    public var frontCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     AVCaptureVideoDataOutput
    
     backCameravideoOutput for AVCaptureSession
     */
    public var backCameravideoOutput: AVCaptureVideoDataOutput?
    
    /**
     AVCaptureVideoDataOutput
    
     frontCameravideoOutput for AVCaptureSession
     */
    public var frontCameravideoOutput: AVCaptureVideoDataOutput?
    
    // 멀티 디바이스 상태 변수
    
    /**
     AVCaptureDevice.Position
    
     when you use ".multiSession" from CameraOptions
     
     this value will switch when you switch screen between main camera and sub camera
     
     */
    public var mainCameraPostion: AVCaptureDevice.Position = .back
    
    /**
     Bool
    
     mirrorMode value for BackCameraDevice
     
     basiclly each device has own value of mirrorMode
     
     */
    public var mirrorBackCamera:Bool = false
    
    /**
     Bool
    
     mirrorMode value for FrontCameraDevice
     
     basiclly each device has own value of mirrorMode
     */
    public var mirrorFrontCamera:Bool = true
    
    // 단일 디바이스 상태 변수
    
    /**
     AVCaptureDevice.Position
    
     Current Camera Potions for SingleSession
     
     */
    public var position: AVCaptureDevice.Position = .back
    
    /**
     AVCaptureSession.Preset
    
     Current Camera Preset
     
     */
    public var preset: AVCaptureSession.Preset = .hd1280x720
    
    /**
     AVCaptureVideoOrientation
    
     Current Camera AVCaptureVideoOrientation
     
     */
    var videoOrientation: AVCaptureVideoOrientation = .portrait
    
    // 큐
    /**
     DispatchQueue
    
     Queue For Session
     
     */
    public var sessionQueue: DispatchQueue?
    
    /**
     DispatchQueue
    
     Queue For Camera Output
     
     */
    public var videoDataOutputQueue: DispatchQueue?
    
    // 권한
    
    /**
     Bool
    
     Camera Permission Bool Value
     
     */
    public var hasCameraPermission:Bool = false
    
    
    // 줌관련 변수
    /**
     CGFloat
    
     BackCamera Current ZoomFactor
     
     */
    public var backCameraCurrentZoomFactor: CGFloat = 1.0
    
    /**
     CGFloat
    
     BackCamera Default ZoomFactor
     
     */
    public var backCameraDefaultZoomFactor: CGFloat = 1.0
    
    /**
     CGFloat
    
     BackCamera Minimum ZoomFactor
     
     */
    public var backCameraMinimumZoonFactor: CGFloat = 1.0
    
    /**
     CGFloat
    
     BackCamera Maximum ZoomFactor
     
     */
    public var backCameraMaximumZoonFactor: CGFloat = 1.0
    
    
    /**
     CGFloat
    
     FrontCamera Current ZoomFactor
     
     */
    public var frontCameraCurrentZoomFactor: CGFloat = 1.0
    
    /**
     CGFloat
    
     FrontCamera Default ZoomFactor
     
     */
    public var frontCameraDefaultZoomFactor: CGFloat = 1.0
    
    /**
     CGFloat
    
     FrontCamera Minimum ZoomFactor
     
     */
    public var frontCameraMinimumZoonFactor: CGFloat = 1.0
    
    /**
     CGFloat
    
     FrontCamera Maximum ZoomFactor
     
     */
    public var frontCameraMaximumZoonFactor: CGFloat = 1.0
    
    
    /**
     Double
    
     Camera Frame Rate
     
     */
    public var frameRate:Double = 30.0
    
    /**
     Double
    
     Camera Maximum Frame Rate
     
     */
    public var maximumFrameRate:Double = 30.0
    
    /**
     CGImage
    
     Thumbnail
     
     you can set own image from setThumbnail(image: UIImage)
     */
    public var thumbnail: CGImage?
    
    /**
     
     CADisplayLink
    
     this will be run when you use thumbnail mode
        
     */
    public var displayLink: CADisplayLink?
    
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
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(handleSessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidStopRunning(_:)), name: .AVCaptureSessionDidStopRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidStartRunning(_:)), name: .AVCaptureSessionDidStartRunning, object: nil)
    }

    @objc func handleSessionRuntimeError(notification: Notification) {
        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError {
            print("Session Runtime Error: \(error)")
        }
    }
    

    @objc private func sessionDidStopRunning(_ notification: Notification) {
        print("Session stopped running: \(notification.object)")
    }
    
    @objc private func sessionDidStartRunning(_ notification: Notification) {
        print("Session started running: \(notification.object)")
    }

    
    /**
     CameraManager Deinit
     */
    deinit {
        print("CamerManager deinit")
    }
    
    /**
     initialize Camera Mananger
     */
    public func initialize() {
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
    
    /**
     unreference for all memory that camera using in include camera session
     
     you must use this function when you finished use this CameraMananger
     for memory leack
     */
    public func unreference() {
        NotificationCenter.default.removeObserver(self)
        
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
        
        self.stopRunningCameraSession()
        
        

        if let frontInput = self.frontCameraCaptureInput {
            self.frontCaptureSession?.removeInput(frontInput)
        }
        
        if let frontOutput = self.frontCameravideoOutput {
            self.frontCaptureSession?.removeOutput(frontOutput)
        }
        
        if let backInput = self.backCameraCaptureInput {
            self.backCaptureSession?.removeInput(backInput)
        }
        
        if let backOutput = self.backCameravideoOutput {
            self.backCaptureSession?.removeOutput(backOutput)
        }
        
        
        
        self.backCaptureSession = nil
        self.backCameraConnection = nil
        self.backCameraCaptureInput = nil
        self.backCameravideoOutput = nil
        
        self.frontCaptureSession = nil
        self.frontCameraConnection = nil
        self.frontCameraCaptureInput = nil
        self.frontCameravideoOutput = nil
        
        self.dualVideoSession = nil
        self.multiFrontCameraConnection = nil
        self.multiBackCameraConnection = nil
        self.multiBackCameraCaptureInput = nil
        self.multiBackCameravideoOutput = nil
        self.multiFrontCameravideoOutput = nil
        
        self.backCamera = nil
        self.frontCamera = nil
        
    }

    
    /**
     check Camera Permission
     */
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





