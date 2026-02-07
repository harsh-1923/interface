//
//  MessageComposerWrapper.swift
//  Interface
//
//  Created by Harsh Sharma on 07/02/26.
//

import SwiftUI

// MARK: - MessageComposerWrapper

struct MessageComposerWrapper: View {

    // MARK: - Alignment side

    enum Side {
        case left
        case right
    }

    // MARK: - Props

    let text: String
    @Binding var likeCount: Int
    var side: Side = .left

    // Ripple effect (forwarded to MessageComposer)
    var amplitude: Double = 12
    var frequency: Double = 15
    var decay: Double = 8
    var speed: Double = 1200
    var duration: Double = 3
    var redIntensity: Double = 0.01

    // Heart path animation (forwarded to MessageComposer)
    var heartAnimationDuration: Double = 0.6
    var heartScaleInDuration: Double = 0.15
    var heartStaggerDelay: Double = 0.12

    // MARK: - Body

    var body: some View {
        HStack {
            if side == .right {
                Spacer(minLength: 0)
            }

            MessageComposer(
                text: text,
                likeCount: $likeCount,
                amplitude: amplitude,
                frequency: frequency,
                decay: decay,
                speed: speed,
                duration: duration,
                redIntensity: redIntensity,
                heartAnimationDuration: heartAnimationDuration,
                heartScaleInDuration: heartScaleInDuration,
                heartStaggerDelay: heartStaggerDelay
            )
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.horizontal) { length, _ in
                length * 0.8
            }

            if side == .left {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        MessageComposerWrapper(
            text: "Hey! This is a left-aligned message bubble.",
            likeCount: .constant(2),
            side: .left
        )

        MessageComposerWrapper(
            text: "And this is a right-aligned message bubble!",
            likeCount: .constant(0),
            side: .right
        )
    }
}
