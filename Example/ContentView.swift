//
//  ContentView.swift
//  Example
//
//  Created by 온석태 on 10/24/24.
//

import SwiftUI
import CameraManagerFrameWork

struct ContentView: View {
    @ObservedObject var vm: ContentViewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            UIKitViewRepresentable(view: vm.cameraMananger?.multiCameraView)
                .frame(height: (UIScreen.main.bounds.width / 9)  * 16 )
        }
    }
}
