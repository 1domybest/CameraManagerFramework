//
//  ContentViewModel.swift
//  Example
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import CameraManagerFrameWork
import UIKit

class ContentViewModel:ObservableObject {
    @Published var cameraMananger: CameraManager?
    @Published var isShowThumnnail: Bool = false
    @Published var isCameraOn: Bool = true
    @Published var brightness:Float = 0.0
    init () {
        self.cameraMananger = CameraManager(cameraOptions: CameraOptions())
        self.cameraMananger?.setThumbnail(image: UIImage(named: "testThumbnail")!)
    }
    
    
    func toggleCamera () {
        if isCameraOn {
            self.isCameraOn = false
            self.cameraMananger?.pauseCamera(showThumbnail: true)
        } else {
            self.isCameraOn = true
            self.cameraMananger?.startCamera()
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
        self.cameraMananger?.changeExposureBias(to: self.brightness)
    }
}
