//
//  MultiCameraViewModel.swift
//  Example
//
//  Created by 온석태 on 10/25/24.
//

import Foundation
import CameraManagerFrameWork
import UIKit

class MultiCameraViewModel:ObservableObject {
    
    @Published var cameraMananger: CameraManager?
    @Published var isShowThumnnail: Bool = false
    @Published var isCameraOn: Bool = true
    @Published var brightness:Float = 0.0
    
    @Published var isFrontMainCamera:Bool = false
    @Published var isTorchOn:Bool = false
    
    @Published var currentScreenMode: CameraScreenMode = .doubleScreen
    
    init () {
        var cameraOption = CameraOptions()
        cameraOption.cameraSessionMode = .multiSession
        cameraOption.cameraScreenMode = .doubleScreen
        cameraOption.enAblePinchZoom = true
        cameraOption.cameraRenderingMode = .normal
        cameraOption.tapAutoFocusAndExposure = true
        cameraOption.showTapAutoFocusAndExposureRoundedRectangle = true
        cameraOption.startPostion = .back
        
        cameraOption.onChangeMainScreenPostion = { currentPosition in
            self.isFrontMainCamera = currentPosition == .front ? true : false
        }
        
        cameraOption.onChangeScreenMode = { currentScreenMode in
            guard let currentScreenMode = currentScreenMode else { return }
            self.currentScreenMode = currentScreenMode
        }
        
        self.cameraMananger = CameraManager(cameraOptions: cameraOption)
        self.cameraMananger?.setThumbnail(image: UIImage(named: "testThumbnail")!)
        self.cameraMananger?.startSession()
    }
    
    deinit {
        print("MultiCameraViewModel deinit")
    }
    
    func unrference () {
        self.cameraMananger?.unreference()
        self.cameraMananger = nil
    }
    
    func toggleCameraScreenMode () {
        
        if !self.isCameraOn { return }
        self.currentScreenMode = currentScreenMode == .doubleScreen ? .singleScreen : .doubleScreen
        self.cameraMananger?.setCameraScreenMode(cameraScreenMode: self.currentScreenMode)
    }
    
    func toggleTorch() {
        self.isTorchOn = self.isTorchOn ? false : true
        self.cameraMananger?.setTorch(onTorch: self.isTorchOn)
    }
    
    func toggleCamera (showThumbnail: Bool) {
        if isCameraOn {
            self.isCameraOn = false
            self.cameraMananger?.pauseCamera(showThumbnail: showThumbnail)
        } else {
            self.isCameraOn = true
            self.isShowThumnnail = false
            self.cameraMananger?.startCameraSession()
        }
        
    }
    
    func toggleThumbnail () {
        if isShowThumnnail {
            self.isShowThumnnail = false
            self.cameraMananger?.setShowThumbnail(isShow: false)
        } else {
            self.isShowThumnnail = true
            self.cameraMananger?.setShowThumbnail(isShow: true)
        }
    }
    
    func toggleMainCameraPosition() {
        if !self.isCameraOn { return }
        self.isFrontMainCamera = isFrontMainCamera ? false : true
        self.cameraMananger?.setMainCameraPostion(mainCameraPostion: self.isFrontMainCamera ? .front : .back)
        
        if self.isFrontMainCamera {
            self.isTorchOn = false
        }
    }
    
    func changeExposure() {
        if !self.isCameraOn { return }
        self.cameraMananger?.changeExposureBias(to: self.brightness)
    }
    
    
}
