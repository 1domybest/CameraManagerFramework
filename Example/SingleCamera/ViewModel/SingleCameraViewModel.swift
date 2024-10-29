//
//  SingleCameraViewModel.swift
//  Example
//
//  Created by 온석태 on 10/25/24.
//

import Foundation
import CameraManagerFrameWork
import UIKit

class SingleCameraViewModel:ObservableObject {
    
    @Published var cameraMananger: CameraManager?
    @Published var isShowThumnnail: Bool = false
    @Published var isCameraOn: Bool = true
    @Published var brightness:Float = 0.0
    
    @Published var isFront:Bool = false
    @Published var isTorchOn:Bool = false
    
    init () {
        var cameraOption = CameraOptions()
        cameraOption.cameraSessionMode = .singleSession
        cameraOption.cameraScreenMode = .singleScreen
        cameraOption.enAblePinchZoom = true
        cameraOption.cameraRenderingMode = .normal
        cameraOption.tapAutoFocusAndExposure = true
        cameraOption.showTapAutoFocusAndExposureRoundedRectangle = true
        cameraOption.startPostion = .back
        
        self.cameraMananger = CameraManager(cameraOptions: cameraOption)
        self.cameraMananger?.setThumbnail(image: UIImage(named: "testThumbnail")!)
        self.cameraMananger?.startSession()
    }
    
    deinit {
        print("SingleCameraViewModel deinit")
    }
    
    func unrference () {
        self.cameraMananger?.unreference()
        self.cameraMananger = nil
    }
    
    func toggleTorch() {
        if isTorchOn {
            self.isTorchOn = false
        } else {
            if !self.isFront {
                self.isTorchOn = true
            }
        }
        
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
    
    func changeExposure() {
        if !self.isCameraOn { return }
        self.cameraMananger?.changeExposureBias(to: self.brightness)
    }
    
    func changePosition() {
        if !self.isCameraOn { return }
        self.isFront = isFront ? false : true
        self.cameraMananger?.setPosition(self.isFront ? .front : .back)
        
        if self.isFront {
            self.isTorchOn = false
        }
    }
}
