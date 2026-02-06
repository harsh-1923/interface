//
//  ContentView.swift
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ExperimentsTab()
                .tabItem {
                    Label("Experiments", systemImage: "flask")
                }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

// MARK: - Home
private struct HomeTab: View {
    var body: some View {
        NavigationStack {
            Text("Home")
                .navigationTitle("Home")
        }
    }
}

// MARK: - Experiments
private struct ExperimentsTab: View {
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
            .navigationTitle("Experiments")
        }
    }
}

// MARK: - Search
private struct SearchTab: View {
    var body: some View {
        NavigationStack {
            Text("Search")
                .navigationTitle("Search")
        }
    }
}

#Preview {
    ContentView()
}
