//
//  LazyView.swift
//  Example
//
//  Created by 온석태 on 10/25/24.
//

import Foundation
import SwiftUI

// LazyView 구현
struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
