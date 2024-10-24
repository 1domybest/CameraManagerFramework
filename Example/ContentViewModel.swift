//
//  ContentViewModel.swift
//  Example
//
//  Created by 온석태 on 10/24/24.
//

import Foundation
import CameraManagerFrameWork

class ContentViewModel:ObservableObject {
    @Published var cameraMananger: CameraManager?
    
    init () {
        self.cameraMananger = CameraManager(cameraSessionMode: .multiSession, cameraViewMode: .doubleScreen, cameraRenderingMode: .normal)
    }
}
