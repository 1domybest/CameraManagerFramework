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
    public var cameraScreenMode: CameraScreenMode
    // 세션 모드
    public var cameraSessionMode: CameraSessionMode
    // 렌더링 모드
    public var cameraRenderingMode: CameraRenderingMode
    
    public var tapAutoFocusAndExposure: Bool
    
    public var showTapAutoFocusAndExposureRoundedRectangle: Bool
    
    public var enAblePinchZoom: Bool
    
    public var onChangeMainScreenPostion: ((AVCaptureDevice.Position) -> Void)?
    
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
