//
//  CameraManagerFrameWork
//  CameraModeEnum
//  HypyG
//
//  CameraRenderingMode
//  CameraScreenMode
//  CameraSessionMode
//
//  Created by 온석태 on 10/2/24.
//
import Foundation

/// Modes for rendering the camera output.
public enum CameraRenderingMode {
    /// Normal rendering mode, where the camera output is displayed directly on the screen.
    case normal
    
    /// Off-screen rendering mode, where the camera output is rendered off-screen.
    case offScreen
}

/// Modes for Camera Screen
public enum CameraScreenMode {
    
    /// Only one screen will show but if you use ``CameraSessionMode/singleSession``
    /// this mode only option you can use
    case singleScreen
    
    /// double screen will show but this mode will work when you use ``CameraSessionMode/multiSession``
    case doubleScreen
}

/// Modes For Camera Session
public enum CameraSessionMode {
    
    /// session for ``AVCaptrueSession``
    case singleSession
    
    ///  session for ``AVCaptureMultiCamSession``
    case multiSession
}
