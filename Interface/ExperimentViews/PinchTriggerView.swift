//
//  PinchTriggerView.swift
//  Interface
//
//  Created by Harsh Sharma on 06/02/26.
//

import SwiftUI

struct PinchTriggerView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: CGFloat = 1.0
    @State private var foldAmount: CGFloat = 0.0

    var body: some View {
        Image("Img")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(scale)
            .layerEffect(
                ShaderLibrary.Fold(
                    .boundingRect,
                    .float(foldAmount)
                ),
                maxSampleOffset: CGSize(width: 400, height: 400)
            )
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = max(0.2, min(1.0, value.magnification))

                        // Pinch in (scale < 1) increases fold: top → red, bottom → blue
                        foldAmount = max(0, min(1, 1 - value.magnification))
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            scale = 1.0
                            opacity = 1.0
                            foldAmount = 0
                        }
                    }
            )
            .padding()
            .navigationTitle("Pinch")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PinchTriggerView()
}
