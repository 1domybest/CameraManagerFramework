//
//  AudioMananger.swift
//  HypyG
//
//  Created by 온석태 on 11/25/23.
//

import AVFoundation
import UIKit

/// Main Class For ``AudioMananger``
/// Base - [`AVFoundation`](https://developer.apple.com/documentation/avfoundation)
public class AudioMananger: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    public var captureSession: AVCaptureSession?
    
    public var audioCaptureDevice: AVCaptureDevice?
    public var audioCaptureInput: AVCaptureDeviceInput?
    
    public var audioOutput: AVCaptureAudioDataOutput?
    
    public var audioConnection: AVCaptureConnection?
    
    public var sessionQueue: DispatchQueue?
    public var audioCaptureQueue: DispatchQueue?
        
    public var audioManagerFrameWorkDelegate: AudioManagerFrameWorkDelegate?
    
    public override init() {
        super.init()

        let attr = DispatchQueue.Attributes()
        sessionQueue = DispatchQueue(label: "cc.otis.audioSessionqueue", attributes: attr)
        audioCaptureQueue = DispatchQueue(label: "cc.otis.audioCaptureQueue", attributes: attr)
    }
    
    /**
     deinitialize ``AudioMananger``
     */
    deinit {
        print("AudioManager deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     initialize ``AudioMananger``
     */
    public func initialize() {
        self.captureSession = AVCaptureSession()
        
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
        
        self.sessionQueue?.async {
            self.captureSession?.startRunning()
        }
    }
    
    func unreference() {
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
    

    public func restartAudioSession() {
        self.initialize()
    }

    /**
     check Audio Permission
     */
    public func checkMicrophonePermission(completion: @escaping (_ succeed: Bool) -> Void) {
        let mediaType = AVMediaType.audio
        
        if AVCaptureDevice.authorizationStatus(for: mediaType) == .authorized {
            completion(true)
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
        case .notDetermined:
            sessionQueue?.suspend()
            AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    completion(granted)
                }
                self.sessionQueue?.resume()
            }
            
        case .denied:
            DispatchQueue.main.async {
                completion(false)
            }
        default:
            break
        }
    }
    
    
    
    /**
     start Audio Session
     
     only Session will Start
     
     but it will work after you used ``pauseAudioSession()``
     
     or begin of make instance about ``AudioMananger``
     */
    @objc
    public func startAudioSession() {
        self.sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
        }
        
    }
    
    /**
     pause Audio Session
     */
    public func pauseAudioSession() {
        self.sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.stopRunning()
        }
    }
    
    /**
     stop Audio Session
     */
    public func stopAudioSession() {
        print("stopAudioInternal")
        sessionQueue?.async { [weak self] in
            guard let self = self else { return }
            if let captureSession = self.captureSession {
                if audioCaptureInput != nil {
                    captureSession.removeInput(audioCaptureInput!)
                    audioCaptureInput = nil
                }
                
                if audioOutput != nil {
                    captureSession.removeOutput(audioOutput!)
                    self.audioOutput = nil
                }
                
                if audioConnection != nil {
                    captureSession.removeConnection(audioConnection!)
                    audioConnection = nil
                }
                
                captureSession.stopRunning()
                self.captureSession = nil
            }
        }
    }
    
   
    
    
   
    
    /**
     Sets Audio Output Delegate

     - Parameters:
       - audioManagerFrameWorkDelegate: delegate
     */
    public func setAudioManagerFrameWorkDelegate(audioManagerFrameWorkDelegate: AudioManagerFrameWorkDelegate) {
        self.audioManagerFrameWorkDelegate = audioManagerFrameWorkDelegate
    }
    
    /**
     captureOutput from Audio Delegate

     - Parameters:
     */
    open func captureOutput(
        _: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from _: AVCaptureConnection
    ) {
        self.audioManagerFrameWorkDelegate?.audioCaptureOutput?(sampleBuffer: sampleBuffer)
    }
}

