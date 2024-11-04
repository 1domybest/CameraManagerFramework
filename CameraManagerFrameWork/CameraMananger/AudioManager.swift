//
//  AudioMananger.swift
//  HypyG
//
//  Created by 온석태 on 11/25/23.
//

import AVFoundation

///
/// 오디오 매니저
///
/// - Parameters:
/// - Returns:
///
public class AudioMananger: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    public var captureSession: AVCaptureSession?
    
    public var audioCaptureDevice: AVCaptureDevice?
    public var audioCaptureInput: AVCaptureDeviceInput?
    
    public var audioOutput: AVCaptureAudioDataOutput?
    
    public var audioConnection: AVCaptureConnection?
    
    public var sessionQueue: DispatchQueue?
    public var audioCaptureQueue: DispatchQueue?
    
    public var hasMicrophonePermission = false
        
    public var audioManagerFrameWorkDelegate: AudioManagerFrameWorkDelegate?
    
    public override init() {
        super.init()
        
        hasMicrophonePermission = false
        
        captureSession = AVCaptureSession()
        
        let attr = DispatchQueue.Attributes()
        sessionQueue = DispatchQueue(label: "cc.otis.audioSessionqueue", attributes: attr)
        audioCaptureQueue = DispatchQueue(label: "cc.otis.audioCaptureQueue", attributes: attr)
    }

    ///
    /// 카메라 deinit 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    deinit {
        print("AudioManager deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    ///
    /// 오디오 세션 시작
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func initialize() {
        checkMicrophonePermission { result in
            if result {
                self.captureSession?.beginConfiguration()
                
                if let audioCaptureDevice = AVCaptureDevice.default(for: .audio) {
                    self.audioCaptureInput = try? AVCaptureDeviceInput(device: audioCaptureDevice)
                    if let audioCaptureInput = self.audioCaptureInput,
                       self.captureSession?.canAddInput(audioCaptureInput) == true
                    {
                        self.captureSession?.addInput(audioCaptureInput)
                    } else {
                        print("Unable to add audio input")
                        self.captureSession?.commitConfiguration()
                        return
                    }
                }
                
                let audioOutput = AVCaptureAudioDataOutput()
                audioOutput.setSampleBufferDelegate(self, queue: self.audioCaptureQueue)
                if self.captureSession?.canAddOutput(audioOutput) == true {
                    self.captureSession?.addOutput(audioOutput)
                    self.audioOutput = audioOutput
                } else {
                    print("Unable to add audio output")
                    self.captureSession?.commitConfiguration()
                    return
                }
                
                self.audioConnection = audioOutput.connection(with: .audio)
                
                self.captureSession?.commitConfiguration()
                
                self.captureSession?.startRunning()
            }
        }
        
       
    }
    
    public func unreference() {
        NotificationCenter.default.removeObserver(self)
        
        self.stopAudioSession()
        self.audioManagerFrameWorkDelegate = nil
        audioCaptureDevice = nil
        audioOutput = nil
        audioCaptureInput = nil
        audioConnection = nil
        sessionQueue = nil
        audioCaptureQueue = nil
        audioCaptureDevice = nil
    }
    
    ///
    /// 오디오 퍼미션 체크 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func checkMicrophonePermission(completion: @escaping (_ succeed: Bool) -> Void) {
        let mediaType = AVMediaType.audio
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            hasMicrophonePermission = true
            completion(true)
        case .notDetermined:
            sessionQueue?.suspend()
            AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
                guard let self = self else { return }
                self.hasMicrophonePermission = granted
                self.sessionQueue?.resume()
                completion(granted)
            }
            
        case .denied:
            hasMicrophonePermission = false
            completion(false)
        default:
            break
        }
    }
    
    
    
    ///
    /// 오디오 세션 시작함수  단 퍼미션확인후 상수에 등록
    ///
    /// - Parameters:
    /// - Returns:
    ///
    @objc
    public func startAudioSession() {
        self.sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
        }
        
    }
    
    public func pauseAudioSession() {
        self.sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.stopRunning()
        }
    }
    
    ///
    /// 오디오 세션 정지 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func stopAudioSession() {
        print("stopAudioInternal")
        sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            if let captureSession = self.captureSession {
                if captureSession.isRunning {
                    captureSession.removeInput(audioCaptureInput!)
                    audioCaptureInput = nil
                    captureSession.removeOutput(audioOutput!)
                    audioOutput = nil
                    audioConnection = nil
                    captureSession.stopRunning()
                }
            }
        }
    }
    
   
    
    
   
    
    ///
    /// output 에서 받은 데이터를 넘겨줄 callback함수를 등록하는 함수
    ///
    /// - Parameters:
    ///    - appendQueueCallback ( AppendQueueProtocol ) : 프로토콜로 등록한 클래스를 넘겨줌
    /// - Returns:
    ///
    public func setAudioManagerFrameWorkDelegate(audioManagerFrameWorkDelegate: AudioManagerFrameWorkDelegate) {
        self.audioManagerFrameWorkDelegate = audioManagerFrameWorkDelegate
    }
    
    ///
    /// 오디오 세션 실행시 매프레임마다 callback 되는 함수
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
        from _: AVCaptureConnection
    ) {
        self.audioManagerFrameWorkDelegate?.audioCaptureOutput?(sampleBuffer: sampleBuffer)
    }
}

