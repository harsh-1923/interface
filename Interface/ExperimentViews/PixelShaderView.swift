//
//  PixelShaderView.swift
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

import SwiftUI

private enum PixelateWavePhase {
    case idle
    case pixelating
    case depixelating
}

struct PixelShaderView: View {
    @State private var isPixelated = false
    @State private var progress: Double = 0
    @State private var phase: PixelateWavePhase = .idle
    @State private var layerWidth: CGFloat = 400

    private let waveDuration: Double = 0.5
    private let maxBlockSize: CGFloat = 12
    private let bandSoftness: CGFloat = 0.08

    var body: some View {
        Image("Img")
            .resizable()
            .scaledToFit()
            .background(GeometryReader { g in Color.clear.preference(key: LayerSizeKey.self, value: g.size.width) })
            .onPreferenceChange(LayerSizeKey.self) { layerWidth = $0 }
            .pixelateWave(
                progress: progress,
                layerWidth: layerWidth,
                bandSoftness: bandSoftness,
                maxBlockSize: maxBlockSize
            )
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                guard phase == .idle else { return }
                if isPixelated {
                    phase = .depixelating
                    progress = 1
                    withAnimation(.easeInOut(duration: waveDuration)) {
                        progress = 0
                    }
                } else {
                    phase = .pixelating
                    progress = 0
                    withAnimation(.easeInOut(duration: waveDuration)) {
                        progress = 1
                    }
                }
            }
            .onChange(of: progress) { _, newProgress in
                if phase == .pixelating, newProgress >= 0.99 {
                    isPixelated = true
                    phase = .idle
                } else if phase == .depixelating, newProgress <= 0.01 {
                    isPixelated = false
                    phase = .idle
                }
            }
            .navigationTitle("Pixel Shader")
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LayerSizeKey: PreferenceKey {
    static var defaultValue: CGFloat { 400 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

#Preview {
    NavigationStack {
        PixelShaderView()
    }
}
