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
                .overlay(
                    VStack {
                        Spacer()
                        
                        Slider(value: $vm.brightness, in: -8...8, step: 0.1)
                        
                        Spacer().frame(height: 20)
                        
                        Button(action: {
                            self.vm.toggleCamera()
                        }, label: {
                            Text("카메라")
                        })
                        
                        Spacer().frame(height: 20)
                        
                        Button(action: {
                            self.vm.toggleThumbnail()
                        }, label: {
                            Text("썸네일")
                        })
                        Spacer().frame(height: 10)
                    }
                )
                .onChange(of: vm.brightness) { value in
                    self.vm.changeExposure()
                }
        }
    }
}
