//
//  CameraManager.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import AVFoundation
import UIKit
import LogManager

/// Main Class For ``CameraManager``
/// Base - [`AVFoundation`](https://developer.apple.com/documentation/avfoundation)
public class CameraManager: NSObject {
    /**
     ``AudioMananger``
     */
    public var audioManager: AudioMananger?
    
    /**
     ``CameraMetalView``
     
     if you use this view make sure you using "singleSession" from CameraOptions
     
     # Code
         var cameraOptions:CameraOptions = CameraOptions()
         cameraOptions.cameraSessionMode = .singleSession
     */
    public var singleCameraView: CameraMetalView?
    
    /**
     ``MultiCameraView``
     
    if you use this view make sure you using "multiSession" from CameraOptions
     
     # Code
         var cameraOptions:CameraOptions = CameraOptions()
         cameraOptions.cameraSessionMode = .multiSession
     */
    public var multiCameraView: MultiCameraView?
        
    /**
     Camera Setting Options ``CameraOptions``
    
     this is  options for Camera
    
     # Code
         var cameraOptions:CameraOptions = `CameraOptions`()
         CameraManager(cameraOptions: cameraOptions)
     */
    public var cameraOptions: CameraOptions?
    
    /**
     ``CameraManagerFrameWorkDelegate``
    
     this is observer from camera output
     */
    public var cameraManagerFrameWorkDelegate: CameraManagerFrameWorkDelegate?
    
    /**
     ``CVPixelBuffer``
    
     this is last frame PixelBuffer from camera output
    
     */
    public var previousImageBuffer: CVPixelBuffer?
    
    /**
     ``CMTime``
    
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
     ``AVCaptureDevice``
    
     backCamera device
     */
    public var backCamera: AVCaptureDevice?
    
    /**
     ``AVCaptureDevice``
    
     frontCamera device
     */
    public var frontCamera: AVCaptureDevice?
    
    
    // 멀티세션 디바이스 세션 변수
    
    /**
     ``AVCaptureMultiCamSession``
    
     MultiCamSession is will be used when you setting ``CameraSessionMode/multiSession`` from ``CameraOptions``
     */
    public var dualVideoSession:AVCaptureMultiCamSession?
    
    /**
     ``AVCaptureConnection``
    
     BackCameraConnection for ``AVCaptureMultiCamSession``
     */
    public var multiBackCameraConnection: AVCaptureConnection?
    
    /**
     ``AVCaptureConnection``
    
     FrontCameraConnection for ``AVCaptureMultiCamSession``
     */
    public var multiFrontCameraConnection: AVCaptureConnection?
    
    /**
     ``AVCaptureDeviceInput``
    
     BackDeviceInput for ``AVCaptureMultiCamSession``
     */
    public var multiBackCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     ``AVCaptureDeviceInput``
    
     FrontDeviceInput for ``AVCaptureMultiCamSession``
     */
    public var multiFrontCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     ``AVCaptureVideoDataOutput``
    
     BackDeviceOutput for ``AVCaptureMultiCamSession``
     */
    public var multiBackCameravideoOutput: AVCaptureVideoDataOutput?
    
    
    /**
     ``AVCaptureVideoDataOutput``
    
     FrontDeviceOutput for ``AVCaptureMultiCamSession``
     */
    public var multiFrontCameravideoOutput: AVCaptureVideoDataOutput?
    
    
    // 단일 디바이스 세션 변수
    
    /**
     ``AVCaptureSession``
    
     backCaptureSession will be used when you setting ``CameraSessionMode/singleSession`` from ``CameraOptions``
     */
    public var backCaptureSession: AVCaptureSession?
    
    /**
     ``AVCaptureSession``
    
     frontCaptureSession will be used when you setting ``CameraScreenMode/singleScreen`` from ``CameraOptions``
     */
    public var frontCaptureSession: AVCaptureSession?
    
    /**
     ``AVCaptureConnection``
    
     backCameraConnection for ``AVCaptureSession``
     */
    public var backCameraConnection: AVCaptureConnection?
    
    /**
     ``AVCaptureConnection``
    
     frontCameraConnection for ``AVCaptureSession``
     */
    public var frontCameraConnection: AVCaptureConnection?
    
    /**
     ``AVCaptureDeviceInput``
    
     backCameraCaptureInput for ``AVCaptureSession``
     */
    public var backCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     ``AVCaptureDeviceInput``
    
     frontCameraCaptureInput for ``AVCaptureSession``
     */
    public var frontCameraCaptureInput: AVCaptureDeviceInput?
    
    /**
     ``AVCaptureVideoDataOutput``
    
     backCameravideoOutput for ``AVCaptureSession``
     */
    public var backCameravideoOutput: AVCaptureVideoDataOutput?
    
    /**
     ``AVCaptureVideoDataOutput``
    
     frontCameravideoOutput for ``AVCaptureSession``
     */
    public var frontCameravideoOutput: AVCaptureVideoDataOutput?
    
    // 멀티 디바이스 상태 변수
    
    /**
     ``AVCaptureDevice.Position``
    
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
    public var mirrorFrontCamera:Bool = false
    
    // 단일 디바이스 상태 변수
    
    /**
     ``AVCaptureDevice.Position``
    
     Current Camera Potions for SingleSession
     
     */
    public var position: AVCaptureDevice.Position = .back
    
    /**
     ``AVCaptureSession/Preset``
    
     Current Camera Preset
     
     */
    public var preset: AVCaptureSession.Preset = .hd1280x720
    
    /**
     ``AVCaptureVideoOrientation``
    
     Current Camera AVCaptureVideoOrientation
     
     */
    var videoOrientation: AVCaptureVideoOrientation = .portrait
    
    // 큐
    /**
     ``DispatchQueue``
    
     Queue For Session
     
     */
    public var sessionQueue: DispatchQueue?
    
    /**
     ``DispatchQueue``
    
     Queue For Camera Output
     
     */
    public var videoDataOutputQueue: DispatchQueue?
    
    
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
     
     ``CADisplayLink``
    
     this will be run when you use thumbnail mode
        
     */
    public var displayLink: CADisplayLink?

    
    var isShowThumbnail: Bool = false
    
    private var torchObservation: NSKeyValueObservation?
    
    public init(cameraOptions: CameraOptions) {
        let _ = LogManager(projectName: "CameraManager")
        self.cameraOptions = cameraOptions
        
        self.isMultiCamSupported = AVCaptureMultiCamSession.isMultiCamSupported
        
        self.position = cameraOptions.startPostion
        self.mainCameraPostion = cameraOptions.startPostion
        
        if cameraOptions.cameraSessionMode == .singleSession || !self.isMultiCamSupported {
            self.cameraOptions?.cameraScreenMode = .singleScreen
        }
        
        super.init()
        
        self.observeTorchState()
        let attr = DispatchQueue.Attributes()
        sessionQueue = DispatchQueue(label: "camera.single.sessionqueue", attributes: attr)
        videoDataOutputQueue = DispatchQueue(label: "camera.single.videoDataOutputQueue")
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(handleSessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidStopRunning(_:)), name: .AVCaptureSessionDidStopRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidStartRunning(_:)), name: .AVCaptureSessionDidStartRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidStartRunning(_:)),
                                               name: .AVCaptureSessionInterruptionEnded, object: nil)
    }

    @objc func handleSessionRuntimeError(notification: Notification) {
        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError {
            print("Session Runtime Error: \(error)")
        }
    }
    
    @objc private func sessionInterruptionEnded(_ notification: Notification) {
        print("Session sessionInterruptionEnded : \(String(describing: notification.object))")
    }
    

    @objc private func sessionDidStopRunning(_ notification: Notification) {
        print("Session stopped running: \(String(describing: notification.object))")
    }
    
    @objc private func sessionDidStartRunning(_ notification: Notification) {
        print("Session started running: \(String(describing: notification.object))")
    }

    
    /**
     ``CameraManager`` Deinit
     */
    deinit {
        print("CamerManager deinit")
    }
    
    /**
     initialize ``CameraMananger``
     */
    public func initialize() {

        if self.cameraOptions?.cameraSessionMode == .multiSession {
            self.setupMultiCaptureSessions()
            
            if self.multiCameraView == nil {
                self.multiCameraView = MultiCameraView(parent: self, appendQueueCallback: self)
            }
            
            if self.cameraOptions?.cameraScreenMode == .singleScreen {
                self.multiCameraView?.smallCameraView?.isHidden = true
            }
        } else {
            if self.singleCameraView == nil {
                self.singleCameraView = CameraMetalView(cameraManagerFrameWorkDelegate: self)
            }
            
            self.maximumFrameRate = 60.0
            self.setupCaptureSessions()
            self.setupGestureRecognizers()
        }
        
        if self.cameraOptions?.useMicrophone ?? true {
            if self.audioManager == nil {
                self.audioManager = AudioMananger()
                self.audioManager?.initialize()
            }
        }
        
        
    }
    
    /**
     restartSession ``AVCaptrueDevice``
     */
    public func restartCameraSession() {

        if self.cameraOptions?.cameraSessionMode == .multiSession {
            self.setupMultiCaptureSessions()
        } else {
            if self.singleCameraView == nil {
                self.singleCameraView = CameraMetalView(cameraManagerFrameWorkDelegate: self)
            }
        }
    }
    
    /**
     unreference for all memory that camera using in include camera session
     
     you must use this function when you finished use this ``CameraMananger``
     for memory leack
     */
    public func unreference() {
        NotificationCenter.default.removeObserver(self)
        
        torchObservation?.invalidate()
        torchObservation = nil
        
        self.audioManager?.unreference()
        self.audioManager = nil
        
        self.multiCameraView?.unreference()
        self.multiCameraView = nil
        
        self.cameraManagerFrameWorkDelegate = nil
        
        
        self.singleCameraView?.unreference()
        self.singleCameraView = nil
        
        self.sessionQueue = nil
        self.videoDataOutputQueue = nil
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
    public func checkCameraPermission(completion: @escaping (_ succeed: Bool) -> Void) {
        let mediaType = AVMediaType.video
        
        if AVCaptureDevice.authorizationStatus(for: mediaType) == .authorized {
            completion(true)
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            completion(true)
            break
        case .notDetermined:
            sessionQueue?.suspend()
            AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
                guard let self = self else { return }
                completion(granted)
                self.sessionQueue?.resume()
            }
            break
        case .denied:
            completion(false)
            break
        default:
            break
        }
    }
    
    /**
     callback For TorchState
     */
    func observeTorchState() {
        // KVO를 사용하여 isTorchActive 속성 감시
        torchObservation = backCamera?.observe(\.isTorchActive, options: [.new, .old]) { [weak self] (device, change) in
            guard let isTorchActive = change.newValue else { return }
            
            self?.cameraOptions?.onChangeTorchState?(isTorchActive)
        }
    }

    
}





