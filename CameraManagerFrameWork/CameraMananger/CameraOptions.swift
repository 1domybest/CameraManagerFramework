//
//  CameraOption.swift
//  CameraManagerFrameWork
//
//  Created by 온석태 on 10/25/24.
//

import Foundation
import AVFoundation

public struct CameraOptions {
    public var startPostion: AVCaptureDevice.Position
    // 화면 모드
    public var cameraViewMode: CameraViewMode
    // 세션 모드
    public var cameraSessionMode: CameraSessionMode
    // 렌더링 모드
    public var cameraRenderingMode: CameraRenderingMode
    
    public var autoFocusAndExposure: Bool
    
    public var showAutoFocusAndExposureRoundedRectangle: Bool
    
    public var enAblePinchZoom: Bool
    
    public init(startPostion: AVCaptureDevice.Position = .back,
                cameraViewMode: CameraViewMode = .doubleScreen,
                cameraSessionMode: CameraSessionMode = .multiSession,
                cameraRenderingMode: CameraRenderingMode = .normal,
                autoFocusAndExposure: Bool = true,
                showAutoFocusAndExposureRoundedRectangle: Bool = true,
                enAblePinchZoom: Bool = true
    ) {
        self.startPostion = startPostion
        self.cameraViewMode = cameraViewMode
        self.cameraSessionMode = cameraSessionMode
        self.cameraRenderingMode = cameraRenderingMode
        self.autoFocusAndExposure = autoFocusAndExposure
        self.showAutoFocusAndExposureRoundedRectangle = showAutoFocusAndExposureRoundedRectangle
        self.enAblePinchZoom = enAblePinchZoom
    }
}
