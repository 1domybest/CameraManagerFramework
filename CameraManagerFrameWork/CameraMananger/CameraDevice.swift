//
//  CameraDevice.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import QuartzCore
import AVFoundation

// 디바이스 관련 메니저
extension CameraManager {
    
    ///
    /// 싱글 세션 카메라 init 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func setupCaptureSessions() {
        self.backCamera = self.findDevice(withPosition: .back)
        self.frontCamera = self.findDevice(withPosition: .front)
        
        guard let backCamera = backCamera else { return }
        guard let frontCamera = frontCamera else { return }
        
        DispatchQueue.main.async {
            // Setup back camera session
            self.backCaptureSession = AVCaptureSession()
            
            if let backCaptureSession = self.backCaptureSession {
                backCaptureSession.beginConfiguration()
                backCaptureSession.sessionPreset = self.preset
                backCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
                
                self.setupInput(for: backCaptureSession, position: .back)
                // Set desired frame rate
                self.setFrameRate(desiredFrameRate: self.frameRate, for: backCamera)
                
                self.setupOutput(for: backCaptureSession, position: .back)
                
                
                backCaptureSession.commitConfiguration()
            }
            
            self.frontCaptureSession = AVCaptureSession()
            
            if let frontCaptureSession = self.frontCaptureSession {
                frontCaptureSession.beginConfiguration()
                frontCaptureSession.sessionPreset = self.preset
                frontCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
                
                self.setupInput(for: frontCaptureSession, position: .front)
                
                // Set desired frame rate
                self.setFrameRate(desiredFrameRate: self.frameRate, for: frontCamera)
                
                self.setupOutput(for: frontCaptureSession, position: .front)
                
                frontCaptureSession.commitConfiguration()
            }
            
            self.sessionQueue?.async {
                if self.position == .back {
                    self.backCaptureSession?.startRunning()
                } else {
                    self.frontCaptureSession?.startRunning()
                }
            }
        }
       
    }
    
    ///
    /// 멀티 세션 카메라 init 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func setupMultiCaptureSessions() {
        self.backCamera = self.findDeviceForMultiSession(withPosition: .back)
        self.frontCamera = self.findDeviceForMultiSession(withPosition: .front)
        
        DispatchQueue.main.async {
            self.dualVideoSession = AVCaptureMultiCamSession()
            if let dualVideoSession = self.dualVideoSession {
                dualVideoSession.beginConfiguration()
                
                self.setupInput(for: dualVideoSession, position: .front, isMultiSession: true)
                self.setupInput(for: dualVideoSession, position: .back, isMultiSession: true)
                
                self.setupOutput(for: dualVideoSession, position: .front, isMultiSession: true)
                self.setupOutput(for: dualVideoSession, position: .back, isMultiSession: true)
                
                dualVideoSession.commitConfiguration()
            }
            
            
            self.sessionQueue?.async {
                self.dualVideoSession?.startRunning()
            }
        }
    }
    
    ///
    /// 카메라 input 설정함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func setupInput(for session: AVCaptureSession, position: AVCaptureDevice.Position, isMultiSession: Bool = false) {
        guard let device = position == .back ? self.backCamera : self.frontCamera else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        do {
            if isMultiSession {
                if position == .back {
                    self.multiBackCameraCaptureInput = input
                } else {
                    self.multiFrontCameraCaptureInput = input
                }
                dualVideoSession?.addInputWithNoConnections(input)
            } else {
                if position == .back {
                    self.backCameraCaptureInput = input
                    backCaptureSession?.canAddInput(input)
                    backCaptureSession?.addInput(input)
                } else {
                    self.frontCameraCaptureInput = input
                    frontCaptureSession?.canAddInput(input)
                    frontCaptureSession?.addInput(input)
                }
            }
        } catch {
            print("에러")
        }
    }
    
    ///
    /// 카메라 output 설정함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func setupOutput(for session: AVCaptureSession, position: AVCaptureDevice.Position, isMultiSession: Bool = false) {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        if isMultiSession {
            if position == .front {
                guard let frontVideoPort = self.multiFrontCameraCaptureInput?.ports(for: .video, sourceDeviceType: frontCamera?.deviceType, sourceDevicePosition: .front).first else {
                    print("Unable to get front video port.")
                    return
                }
                
                if dualVideoSession?.canAddOutput(videoOutput) ?? false {
                    dualVideoSession?.addOutputWithNoConnections(videoOutput)
                }
                
                let frontOutputConnection = AVCaptureConnection(inputPorts: [frontVideoPort], output: videoOutput)
                
                guard dualVideoSession?.canAddConnection(frontOutputConnection) ?? false else {
                    print("no connection to the front camera video data output")
                    return
                }
                
                dualVideoSession?.addConnection(frontOutputConnection)
                frontOutputConnection.videoOrientation = .portrait
                frontOutputConnection.isVideoMirrored = true
                self.multiFrontCameraConnection = frontOutputConnection
                
            } else {
                
                guard let backVideoPort = self.multiBackCameraCaptureInput?.ports(for: .video, sourceDeviceType: backCamera?.deviceType, sourceDevicePosition: .back).first else { return }
                
                if dualVideoSession?.canAddOutput(videoOutput) ?? false {
                    dualVideoSession?.addOutputWithNoConnections(videoOutput)
                }
                
                let backOutputConnection = AVCaptureConnection(inputPorts: [backVideoPort], output: videoOutput)
                
                guard dualVideoSession?.canAddConnection(backOutputConnection) ?? false else {
                    print("no connection to the back camera video data output")
                    return
                }
                
                dualVideoSession?.addConnection(backOutputConnection)
                backOutputConnection.videoOrientation = .portrait
                backOutputConnection.isVideoMirrored = false
                self.multiBackCameraConnection = backOutputConnection
            }
        } else {
            if session.canAddOutput(videoOutput) {
                if isMultiSession {
                    
                    session.addOutputWithNoConnections(videoOutput)
                } else {
                    session.addOutput(videoOutput)
                }
                
            } else {
                fatalError("Could not add video output")
            }
            
            videoOutput.connections.first?.videoOrientation = videoOrientation
            
            if position == .front {
                self.frontCameravideoOutput = videoOutput
                self.frontCameraConnection = videoOutput.connection(with: .video)
                self.frontCameraConnection?.isVideoMirrored = true
            } else {
                self.backCameravideoOutput = videoOutput
                self.backCameraConnection = videoOutput.connection(with: .video)
                self.backCameraConnection?.isVideoMirrored = false
            }
        }
    }
    
    ///
    /// 사용하고있는 기기의 방향에 따른 기기정보 가져오는 함수
    ///
    /// - Parameters:
    ///     - position ( AVCaptureDevice ) : 카메라 방향
    /// - Returns: AVCaptureDevice?
    ///
    public func findDevice(withPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        var deviceTypes = [AVCaptureDevice.DeviceType]()
        
        if #available(iOS 13.0, *) {
            deviceTypes.append(contentsOf: [.builtInDualWideCamera])
            deviceTypes.append(contentsOf: [.builtInTripleCamera])
            self.isUltraWideCamera = true
        }
        
        if deviceTypes.isEmpty {
            isUltraWideCamera = false
        }
        
        deviceTypes.append(contentsOf: [.builtInWideAngleCamera])
        
        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: position
        ).devices
        
        for device in devices {
            if let tripleCamera = devices.first(where: { $0.deviceType == .builtInTripleCamera }) {
                // 트리플 카메라를 가장 높은 우선순위로 선택
                if position == .back {
                    backCameraMinimumZoonFactor = tripleCamera.minAvailableVideoZoomFactor
                    backCameraMaximumZoonFactor = tripleCamera.maxAvailableVideoZoomFactor
                    backCameraDefaultZoomFactor = 2.0
                    backCameraCurrentZoomFactor = backCameraDefaultZoomFactor
                    
                    print("트리플 카메라 - 후면 - 최소줌 \(backCameraMinimumZoonFactor) 최대줌\(backCameraMaximumZoonFactor) 기본줌 \(backCameraDefaultZoomFactor)")
                } else {
                    frontCameraMinimumZoonFactor = tripleCamera.minAvailableVideoZoomFactor
                    frontCameraMaximumZoonFactor = tripleCamera.maxAvailableVideoZoomFactor
                    frontCameraDefaultZoomFactor = 1.0
                    frontCameraCurrentZoomFactor = frontCameraDefaultZoomFactor
                    print("트리플 카메라 - 전면 - 최소줌 \(frontCameraMinimumZoonFactor) 최대줌\(frontCameraMaximumZoonFactor) 기본줌 \(frontCameraDefaultZoomFactor)")
                }
                return tripleCamera
            } else if let dualWideCamera = devices.first(where: { $0.deviceType == .builtInDualWideCamera }) {
                if position == .back {
                    // 트리플 카메라가 없으면 듀얼 와이드 카메라 선택
                    backCameraMinimumZoonFactor = dualWideCamera.minAvailableVideoZoomFactor
                    backCameraMaximumZoonFactor = dualWideCamera.maxAvailableVideoZoomFactor
                    backCameraDefaultZoomFactor = 2.0
                    backCameraCurrentZoomFactor = backCameraDefaultZoomFactor
                    
                    print("듀얼 카메라 - 후면 - 최소줌 \(backCameraMinimumZoonFactor) 최대줌\(backCameraMaximumZoonFactor) 기본줌 \(backCameraDefaultZoomFactor)")
                } else {
                    frontCameraMinimumZoonFactor = dualWideCamera.minAvailableVideoZoomFactor
                    frontCameraMaximumZoonFactor = dualWideCamera.maxAvailableVideoZoomFactor
                    frontCameraDefaultZoomFactor = 1.0
                    frontCameraCurrentZoomFactor = frontCameraDefaultZoomFactor
                    print("듀얼 카메라 - 전면 - 최소줌 \(frontCameraMinimumZoonFactor) 최대줌\(frontCameraMaximumZoonFactor) 기본줌 \(frontCameraDefaultZoomFactor)")
                }
                return dualWideCamera
            } else if let normalCamera = devices.first(where: { $0.deviceType == .builtInWideAngleCamera }) {
                if position == .back {
                    // 트리플 카메라가 없으면 듀얼 와이드 카메라 선택
                    backCameraMinimumZoonFactor = normalCamera.minAvailableVideoZoomFactor
                    backCameraMaximumZoonFactor = normalCamera.maxAvailableVideoZoomFactor
                    backCameraDefaultZoomFactor = 1.0
                    backCameraCurrentZoomFactor = backCameraDefaultZoomFactor
                    
                    print("노멀 카메라 - 후면 - 최소줌 \(backCameraMinimumZoonFactor) 최대줌\(backCameraMaximumZoonFactor) 기본줌 \(backCameraDefaultZoomFactor)")
                } else {
                    frontCameraMinimumZoonFactor = normalCamera.minAvailableVideoZoomFactor
                    frontCameraMaximumZoonFactor = normalCamera.maxAvailableVideoZoomFactor
                    frontCameraDefaultZoomFactor = 1.0
                    frontCameraCurrentZoomFactor = frontCameraDefaultZoomFactor
                    
                    print("노멀 카메라 - 전면 - 최소줌 \(frontCameraMinimumZoonFactor) 최대줌\(frontCameraMaximumZoonFactor) 기본줌 \(frontCameraDefaultZoomFactor)")
                }
                return normalCamera
            }
            
            
        }
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
  
    
    ///
    /// 멀티세션에서 사용할 디바이스의 카메라 가져오기
    ///
    /// - Parameters:
    ///     - position ( AVCaptureDevice ) : 카메라 방향
    /// - Returns: AVCaptureDevice?
    ///
    public  func findDeviceForMultiSession(withPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        var deviceTypes = [AVCaptureDevice.DeviceType]()
        
        if #available(iOS 13.0, *) {
            deviceTypes.append(contentsOf: [.builtInDualWideCamera])
            deviceTypes.append(contentsOf: [.builtInTripleCamera])
            self.isUltraWideCamera = true
        }
        
        if deviceTypes.isEmpty {
            isUltraWideCamera = false
        }
        
        deviceTypes.append(contentsOf: [.builtInWideAngleCamera])
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: position
        )
        
        // 지원되는 멀티 카메라 세트 확인
        let supportedDeviceSets = discoverySession.supportedMultiCamDeviceSets
        
        for device in supportedDeviceSets {
            // 지원되는 멀티 카메라 세트 내에서 장치 선택
            if let tripleCamera = device.first(where: { $0.deviceType == .builtInTripleCamera && $0.position == position }) {
                if position == .back {
                    backCameraMinimumZoonFactor = tripleCamera.minAvailableVideoZoomFactor
                    backCameraMaximumZoonFactor = tripleCamera.maxAvailableVideoZoomFactor
                    backCameraDefaultZoomFactor = 2.0
                    backCameraCurrentZoomFactor = backCameraDefaultZoomFactor
                    
                    print("트리플 카메라 - 후면 - 최소줌 \(backCameraMinimumZoonFactor) 최대줌\(backCameraMaximumZoonFactor) 기본줌 \(backCameraDefaultZoomFactor)")
                } else {
                    frontCameraMinimumZoonFactor = tripleCamera.minAvailableVideoZoomFactor
                    frontCameraMaximumZoonFactor = tripleCamera.maxAvailableVideoZoomFactor
                    frontCameraDefaultZoomFactor = 1.0
                    frontCameraCurrentZoomFactor = frontCameraDefaultZoomFactor
                    print("트리플 카메라 - 전면 - 최소줌 \(frontCameraMinimumZoonFactor) 최대줌\(frontCameraMaximumZoonFactor) 기본줌 \(frontCameraDefaultZoomFactor)")
                }
                return tripleCamera
            } else if let dualWideCamera = device.first(where: { $0.deviceType == .builtInDualWideCamera && $0.position == position }) {
                if position == .back {
                    // 트리플 카메라가 없으면 듀얼 와이드 카메라 선택
                    backCameraMinimumZoonFactor = dualWideCamera.minAvailableVideoZoomFactor
                    backCameraMaximumZoonFactor = dualWideCamera.maxAvailableVideoZoomFactor
                    backCameraDefaultZoomFactor = 2.0
                    backCameraCurrentZoomFactor = backCameraDefaultZoomFactor
                    
                    print("듀얼 카메라 - 후면 - 최소줌 \(backCameraMinimumZoonFactor) 최대줌\(backCameraMaximumZoonFactor) 기본줌 \(backCameraDefaultZoomFactor)")
                } else {
                    frontCameraMinimumZoonFactor = dualWideCamera.minAvailableVideoZoomFactor
                    frontCameraMaximumZoonFactor = dualWideCamera.maxAvailableVideoZoomFactor
                    frontCameraDefaultZoomFactor = 1.0
                    frontCameraCurrentZoomFactor = frontCameraDefaultZoomFactor
                    print("듀얼 카메라 - 전면 - 최소줌 \(frontCameraMinimumZoonFactor) 최대줌\(frontCameraMaximumZoonFactor) 기본줌 \(frontCameraDefaultZoomFactor)")
                }
                return dualWideCamera
            } else if let normalCamera = device.first(where: { $0.deviceType == .builtInWideAngleCamera && $0.position == position }) {
                if position == .back {
                    // 트리플 카메라가 없으면 듀얼 와이드 카메라 선택
                    backCameraMinimumZoonFactor = normalCamera.minAvailableVideoZoomFactor
                    backCameraMaximumZoonFactor = normalCamera.maxAvailableVideoZoomFactor
                    backCameraDefaultZoomFactor = 1.0
                    backCameraCurrentZoomFactor = backCameraDefaultZoomFactor
                    
                    print("노멀 카메라 - 후면 - 최소줌 \(backCameraMinimumZoonFactor) 최대줌\(backCameraMaximumZoonFactor) 기본줌 \(backCameraDefaultZoomFactor)")
                } else {
                    frontCameraMinimumZoonFactor = normalCamera.minAvailableVideoZoomFactor
                    frontCameraMaximumZoonFactor = normalCamera.maxAvailableVideoZoomFactor
                    frontCameraDefaultZoomFactor = 1.0
                    frontCameraCurrentZoomFactor = frontCameraDefaultZoomFactor
                    
                    print("노멀 카메라 - 전면 - 최소줌 \(frontCameraMinimumZoonFactor) 최대줌\(frontCameraMaximumZoonFactor) 기본줌 \(frontCameraDefaultZoomFactor)")
                }
                return normalCamera
            }
        }
        
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }

    
    ///
    /// 카메라 세션 시작함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func startCamera() {
        sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            if self.dualVideoSession != nil {
                self.dualVideoSession?.startRunning()
            } else {
                if self.position == .front {
                    self.frontCaptureSession?.startRunning()
                } else {
                    self.backCaptureSession?.startRunning()
                }
            }
            self.setShowThumbnail(isShow: false)
        }
    }
    
    ///
    /// 카메라 세션 정지함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func stopCamera() {
        sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            
            if displayLink != nil {
                displayLink?.invalidate() // DisplayLink를 중지
                displayLink = nil
                self.multiCameraView?.mainCameraView?.showThumbnail = false
                self.singleCameraView?.showThumbnail = false
            }
            
            self.frontCaptureSession?.stopRunning()
            self.backCaptureSession?.stopRunning()
            self.dualVideoSession?.stopRunning()
        }
    }
    
    ///
    /// 카메라 세션 일시정지 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func pauseCamera(showThumbnail: Bool) {
        sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            
            self.frontCaptureSession?.stopRunning()
            self.backCaptureSession?.stopRunning()
            self.dualVideoSession?.stopRunning()
            
            if showThumbnail {
                self.setShowThumbnail(isShow: showThumbnail)
            }
        }
    }
    
    public func setShowThumbnail(isShow: Bool) {
        DispatchQueue.main.async {
            if isShow {
                if self.dualVideoSession != nil {
                    if let thumbnail = self.thumbnail {
                        self.multiCameraView?.mainCameraView?.setThumbnail(cgImage: thumbnail)
                    }
                    
                    self.multiCameraView?.smallCameraView?.isHidden = true
                    self.multiCameraView?.mainCameraView?.showThumbnail = true
                } else {
                    
                    if let thumbnail = self.thumbnail {
                        self.singleCameraView?.setThumbnail(cgImage: thumbnail)
                    }
                    
                    self.singleCameraView?.showThumbnail = true
                }
                
                self.startDisplayLink()
            } else {
                if self.displayLink != nil {
                    
                    if self.dualVideoSession != nil {
                        self.multiCameraView?.smallCameraView?.isHidden = false
                        self.multiCameraView?.mainCameraView?.showThumbnail = false
                        self.singleCameraView?.showThumbnail = false
                    }
                    
                    self.stopDisplayLink()
                }
            }
           
            
        }
    }
    
    public func startDisplayLink() {
         displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
         // iOS 10 이상에서는 preferredFramesPerSecond를 사용하여 프레임 속도 조절
         displayLink?.preferredFramesPerSecond = Int(self.frameRate) // 초당 30프레임
        
         displayLink?.add(to: .main, forMode: .common)
    }
    
    public func stopDisplayLink() {
        self.displayLink?.invalidate() // DisplayLink를 중지
        self.displayLink = nil
    }
    
    
    @objc public func handleDisplayLink(_ displayLink: CADisplayLink) {
        // 여기에서 프레임 처리 로직을 실행
        if !(self.frontCaptureSession?.isRunning ?? false && self.backCaptureSession?.isRunning ?? false && self.dualVideoSession?.isRunning ?? false) {
//            guard let thumbnail = self.thumbnail else { return }
//            
//            self.renderingThumbnailFrame(pixelBuffer: thumbnail, sourcePostion: self.mainCameraPostion)
            if self.dualVideoSession != nil {
                self.multiCameraView?.mainCameraView?.setNeedsDisplay()
            } else {
                self.singleCameraView?.setNeedsDisplay()
            }
        }
    }
    
    ///
    /// 캡처세션의 해상도를 설정하는 함수
    ///
    /// - Parameters:
    ///    - preset ( AVCaptureSession.Preset ) : 해상도
    /// - Returns:
    ///
    public  func setPreset(_ preset: AVCaptureSession.Preset) {
        guard let captureSession = backCaptureSession else { return }
        
        if captureSession.isRunning && self.preset != preset {
            self.preset = preset
            sessionQueue?.async { [weak self] in
                self?.switchPreset()
            }
        } else {
            self.preset = preset
        }
    }
    
    ///
    /// 캡처세션의 해상도변경 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func switchPreset() {
        guard let captureSession = backCaptureSession else { return }
        
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(preset) {
            captureSession.sessionPreset = preset
        } else {
            if captureSession.canSetSessionPreset(.vga640x480) {
                captureSession.sessionPreset = .vga640x480
                print("Preset not supported, using default")
            } else {
                print("Unable to set session preset")
                captureSession.commitConfiguration()
                return
            }
        }
        captureSession.commitConfiguration()
    }
}

extension CameraManager:CameraManagerFrameWorkDelegate {
    public func videoCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position) {
        self.cameraManagerFrameWorkDelegate?.videoCaptureOutput?(pixelBuffer: pixelBuffer, time: time, position: position)
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    ///
    /// 카메라 세션 실행시 매프레임마다 callback 되는 함수
    ///
    /// - Parameters:
    ///    - _ ( AVCaptureOutput ) : 아웃풋에대한 정보
    ///    - sampleBuffer ( AVCaptureConnection ) : 카메라에서 받아온 샘플정보
    ///    - from ( AVCaptureConnection ) :기기정보[카메라 혹은 마이크]
    /// - Returns:
    ///
    open func captureOutput(
        _: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        self.renderingCameraFrame(sampleBuffer: sampleBuffer, connection: connection)
    }
    
    func renderingCameraFrame(
        sampleBuffer: CMSampleBuffer,
        connection: AVCaptureConnection
    ) {
        guard var pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
              return
          }
        guard var sourcePostion: AVCaptureDevice.Position = connection.inputPorts.first?.sourceDevicePosition else { return }
          // 타임스탬프 추출
        var timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        
        self.previousImageBuffer = pixelBuffer
        self.previousTimeStamp = timestamp
        
        if self.cameraRenderingMode == .offScreen {
            
            self.cameraManagerFrameWorkDelegate?.videoOffscreenRenderCaptureOutput?(pixelBuffer: pixelBuffer, time: timestamp, position: sourcePostion)
            self.cameraManagerFrameWorkDelegate?.videoOffscreenRenderCaptureOutput?(CMSampleBuffer: sampleBuffer, position: sourcePostion)
            
        } else {
            
            var newPixelBuffer:CVPixelBuffer? = self.cameraManagerFrameWorkDelegate?.videoChangeAbleCaptureOutput?(pixelBuffer: pixelBuffer, time: timestamp, position: sourcePostion)
            
            var newCMSampleBuffer:CMSampleBuffer? = self.cameraManagerFrameWorkDelegate?.videoChangeAbleCaptureOutput?(CMSampleBuffer: sampleBuffer, position: sourcePostion)
            
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