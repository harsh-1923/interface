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

struct MessageComposerView: View {
    @State private var origin: CGPoint = .zero
    @State private var likeCount: Int = 0;
    @State private var counter: Int = 0
    @State private var amplitude: Double = 12
    @State private var frequency: Double = 15
    @State private var decay: Double = 8
    @State private var speed: Double = 1200
    @State private var duration: Double = 3
    @State private var redIntensity: Double = 0.01

    private let message = """
    This is a message bubble. The height of this bubble should grow
    naturally based on the text length, without any fixed height.
    This is a message bubble. The height of this bubble should grow
    naturally based on the text length, without any fixed height.
    """

    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {

                // Message content + bubble
                Text(message)
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

                // Like count pill
                LikeCountView(count: $likeCount)
                    .offset(x: 8, y: -18)
            }
            

            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("Message Composer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Like Count Pill

struct LikeCountView: View {
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
    NavigationStack {
        MessageComposerView()
    }
}
