//
//  ContentView.swift
//  Example
//
//  Created by 온석태 on 10/24/24.
//

import SwiftUI
import CameraManagerFrameWork

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    
                    NavigationLink(destination: LazyView(SingleCameraView())) {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.blue)
                            .frame(width: 200, height: 100)
                            .overlay(
                                Text("Single_Camera")
                                    .bold()
                                    .foregroundColor(.white)
                            )
                    }
                    
                    Spacer().frame(height: 30)
                    
                    NavigationLink(destination: LazyView(MultiCameraView())) {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.red)
                            .frame(width: 200, height: 100)
                            .overlay(
                                Text("Multi_Camera")
                                    .bold()
                                    .foregroundColor(.white)
                            )
                    }
                    
                    Spacer()
                }
            }
            
        }
    }
}
