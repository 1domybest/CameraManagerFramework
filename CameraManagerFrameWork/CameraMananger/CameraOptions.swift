//
//  CameraOption.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/25/24.
//

import Foundation
import AVFoundation

/// CameraOptions For CameraManager
public struct CameraOptions {
    
    /**
     AVCaptureDevice.Position
     
     when camera session started first time
     
     you can chose what position you want
     */
    public var startPostion: AVCaptureDevice.Position
    
    /**
     CameraScreenMode
     */
    public var cameraScreenMode: CameraScreenMode
    
    /**
     CameraSessionMode
     */
    public var cameraSessionMode: CameraSessionMode
    
    /**
     CameraRenderingMode
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
     
     if you set `"tapAutoFocusAndExposure"` this true
     
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
     Callback when you using `".multiSession"`
     
     and the mainCamera View Switch between FrontCamera and BackCamera
     
     this callback will be called with postion
     */
    public var onChangeMainScreenPostion: ((AVCaptureDevice.Position) -> Void)?
    
    /**
     Callback when you using `".multiSession"`
     
     and the View Switch between singleScreen and doubleScreen
     
     this callback will be called with `"screenMode"`
     */
    public var onChangeScreenMode: ((CameraScreenMode?) -> Void)?
    
    public init(startPostion: AVCaptureDevice.Position = .back,
                cameraScreenMode: CameraScreenMode = .singleScreen,
                cameraSessionMode: CameraSessionMode = .singleSession,
                cameraRenderingMode: CameraRenderingMode = .normal,
                autoFocusAndExposure: Bool = true,
                showAutoFocusAndExposureRoundedRectangle: Bool = true,
                enAblePinchZoom: Bool = true,
                onChangeMainScreenPostion: ((AVCaptureDevice.Position) -> Void)? = { _ in },
                onChangeScreenMode: ((CameraScreenMode?) -> Void)? = { _ in }
    ) {
        self.startPostion = startPostion
        self.cameraScreenMode = cameraScreenMode
        self.cameraSessionMode = cameraSessionMode
        self.cameraRenderingMode = cameraRenderingMode
        self.tapAutoFocusAndExposure = autoFocusAndExposure
        self.showTapAutoFocusAndExposureRoundedRectangle = showAutoFocusAndExposureRoundedRectangle
        self.onChangeScreenMode = onChangeScreenMode
        self.enAblePinchZoom = enAblePinchZoom
    }
}
