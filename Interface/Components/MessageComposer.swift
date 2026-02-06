//
//  MessageComposer.swift
//  Interface
//
//  Created by Harsh Sharma on 06/02/26.
//

import SwiftUI

// MARK: - Custom message colors (light blue palette)
private extension Color {
    /// Very light desaturated blue/lilac — message bubble background
    static let messageBubbleBg = Color(red: 238/255, green: 245/255, blue: 252/255)
    /// Very light cool gray-blue — like count capsule background
    static let likeCountCapsuleBg = Color(red: 228/255, green: 235/255, blue: 240/255)
}

// MARK: - MessageComposer Component

struct MessageComposer: View {
    let text: String
    let initialLikeCount: Int

    @State private var origin: CGPoint = .zero
    @State private var likeCount: Int = 0
    @State private var counter: Int = 0
    @State private var amplitude: Double = 12
    @State private var frequency: Double = 15
    @State private var decay: Double = 8
    @State private var speed: Double = 1200
    @State private var duration: Double = 3
    @State private var redIntensity: Double = 0.01

    init(text: String, initialLikeCount: Int = 0) {
        self.text = text
        self.initialLikeCount = initialLikeCount
        _likeCount = State(initialValue: initialLikeCount)
    }

    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {

                // Message content + bubble
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(RoundedRectangle(cornerRadius: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.messageBubbleBg)
                    )
                    .modifier(
                        RippleEffect(
                            at: origin,
                            trigger: counter,
                            duration: duration,
                            amplitude: amplitude,
                            frequency: frequency,
                            decay: decay,
                            speed: speed,
                            redIntensity: redIntensity
                        )
                    )
                    .onTapGesture(count: 2) { location in
                        origin = location
                        counter -= 1
                        likeCount += 1
                    }

                if(likeCount > 0) {
                    LikeCountPill(count: $likeCount)
                        .offset(x: 8, y: -18)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Like Count Pill

private struct LikeCountPill: View {
    @Binding var count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)

            Text("\(count)")
                .monospacedDigit()
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.likeCountCapsuleBg)
        )
        .onTapGesture {
            count += 1
        }
        .overlay(
            Capsule()
                .stroke(Color.white, lineWidth: 3)
        )
        .animation(.default, value: count)
    }
}

#Preview {
    MessageComposer(
        text: "Hello! This is a reusable message composer component.",
        initialLikeCount: 3
    )
}
