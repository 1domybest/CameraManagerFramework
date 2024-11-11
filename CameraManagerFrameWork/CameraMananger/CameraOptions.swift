//
//  CameraOption.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/25/24.
//

import Foundation
import AVFoundation

/**
 ``CameraOptions`` For ``CameraManager``
 Camera Setting Options

 this is  options for Camera

 # Code
     var cameraOptions:CameraOptions = CameraOptions()
     CameraManager(cameraOptions: cameraOptions)
 */
public struct CameraOptions {
    
    /**
     ``AVCaptureDevice/Position`` first postion
     
     when camera session started first time
     
     you can chose what position you want
     */
    public var startPostion: AVCaptureDevice.Position
    
    /**
     ``CameraScreenMode``
     */
    public var cameraScreenMode: CameraScreenMode
    
    /**
     ``CameraSessionMode``
     */
    public var cameraSessionMode: CameraSessionMode
    
    /**
     ``CameraRenderingMode``
     */
    public var cameraRenderingMode: CameraRenderingMode
    
    /**
     tapAutoFocusAndExposure
     
     if its's `true` when you tab screen
     
     Focus and Exposure will be adjusted automatically.
     */
    public var tapAutoFocusAndExposure: Bool
    
    /**
     showTapAutoFocusAndExposureRoundedRectangle
     
     if you set ``CameraOptions/tapAutoFocusAndExposure`` this true
     
     and
     
     if its's `"true"` when you tab screen
     
     yellow box  will show on screen
     */
    public var showTapAutoFocusAndExposureRoundedRectangle: Bool
    
    /**
     if its's `"true"`
     
     the pinch zoom will turn on
     */
    public var enAblePinchZoom: Bool
    
    /**
     if its's `"true"`
     
     the microphone will turn on
     */
    public var useMicrophone: Bool
    
    /**
     Callback when you using ``CameraSessionMode/multiSession``
     
     and the mainCamera View Switch between FrontCamera and BackCamera
     
     this callback will be called with postion
     */
    public var onChangeMainScreenPostion: ((AVCaptureDevice.Position) -> Void)?
    
    /**
     Callback when you using ``CameraSessionMode/multiSession``
     
     and the View Switch between singleScreen and doubleScreen
     
     this callback will be called with ``CameraScreenMode``
     */
    public var onChangeScreenMode: ((CameraScreenMode?) -> Void)?
    
    /**
     Camera Size ``CGSize``
     */
    public var cameraSize: CGSize
    
    public init(startPostion: AVCaptureDevice.Position = .back,
                cameraScreenMode: CameraScreenMode = .singleScreen,
                cameraSessionMode: CameraSessionMode = .singleSession,
                cameraRenderingMode: CameraRenderingMode = .normal,
                autoFocusAndExposure: Bool = true,
                useMicrophone: Bool = true,
                showAutoFocusAndExposureRoundedRectangle: Bool = true,
                enAblePinchZoom: Bool = true,
                cameraSize:CGSize = CGSize(width: 720, height: 1280),
                onChangeMainScreenPostion: ((AVCaptureDevice.Position) -> Void)? = { _ in },
                onChangeScreenMode: ((CameraScreenMode?) -> Void)? = { _ in }
    ) {
        self.startPostion = startPostion
        self.cameraSize = cameraSize
        self.cameraScreenMode = cameraScreenMode
        self.cameraSessionMode = cameraSessionMode
        self.cameraRenderingMode = cameraRenderingMode
        self.useMicrophone = useMicrophone
        self.tapAutoFocusAndExposure = autoFocusAndExposure
        self.showTapAutoFocusAndExposureRoundedRectangle = showAutoFocusAndExposureRoundedRectangle
        self.onChangeScreenMode = onChangeScreenMode
        self.enAblePinchZoom = enAblePinchZoom
    }
}
