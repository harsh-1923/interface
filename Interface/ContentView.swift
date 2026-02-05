//
//  ContentView.swift
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Message Ripple") {
                    MessageRippleView()
                }
                NavigationLink("Pixel Shader") {
                    PixelShaderView()
                }
                NavigationLink("Path Animation") {
                    PathAnimationDemo()
                }
                NavigationLink("Pinch Trigger") {
                    PinchTriggerView()
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
