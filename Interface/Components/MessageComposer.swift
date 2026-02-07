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

// MARK: - Flying Heart Model

/// Represents a single heart animating along the path
private struct FlyingHeart: Identifiable {
    let id: UUID
    var scale: CGFloat = 0
    var progress: CGFloat = 0
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

    // Heart path animation state — supports multiple simultaneous hearts
    @State private var flyingHearts: [FlyingHeart] = []
    @State private var activeTimers: [UUID: Timer] = [:]
    private let heartAnimationDuration: Double = 0.6
    private let scaleInDuration: Double = 0.15

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
                    .overlay {
                        GeometryReader { geometry in
                            let path = straightPath(in: geometry.size)

                            ForEach(flyingHearts) { heart in
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                                    .scaleEffect(heart.scale)
                                    .position(
                                        positionOnPath(
                                            path: path,
                                            progress: heart.progress
                                        )
                                    )
                            }
                        }
                    }
                    .onTapGesture(count: 2) { location in
                        origin = location
                        counter -= 1
                        spawnHeartAnimation()
                    }

                if(likeCount > 0) {
                    LikeCountPill(count: $likeCount)
                        .offset(x: 8, y: -18)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .onDisappear {
            for timer in activeTimers.values { timer.invalidate() }
            activeTimers.removeAll()
        }
    }

    // MARK: - Path helpers

    /// A straight vertical path from bottom-right to top-right of the bubble
    private func straightPath(in size: CGSize) -> Path {
        let inset: CGFloat = 16
        var path = Path()
        path.move(to: CGPoint(x: size.width - inset, y: size.height))
        path.addLine(to: CGPoint(x: size.width - inset, y: 0))
        return path
    }

    /// Get the position at a given progress (0...1) along a path
    private func positionOnPath(path: Path, progress: CGFloat) -> CGPoint {
        let t = max(0, min(1, progress))
        guard t > 0 else {
            return path.trimmedPath(from: 0, to: 0.001).currentPoint
                ?? path.currentPoint ?? .zero
        }
        let trimmed = path.trimmedPath(from: 0, to: t)
        return trimmed.currentPoint ?? path.currentPoint ?? .zero
    }

    // MARK: - Animation

    private func easeInOut(_ t: Double) -> CGFloat {
        CGFloat(t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2)
    }

    /// Spawn a new independent heart animation — multiple can run at once
    private func spawnHeartAnimation() {
        let heart = FlyingHeart(id: UUID())
        flyingHearts.append(heart)

        let startTime = Date()
        let frameRate: TimeInterval = 1.0 / 60.0
        let totalDuration = scaleInDuration + heartAnimationDuration
        let heartID = heart.id

        let timer = Timer.scheduledTimer(
            withTimeInterval: frameRate,
            repeats: true
        ) { timer in
            let elapsed = Date().timeIntervalSince(startTime)

            if elapsed >= totalDuration {
                timer.invalidate()
                activeTimers.removeValue(forKey: heartID)
                flyingHearts.removeAll { $0.id == heartID }
                likeCount += 1
                return
            }

            // Find and update this heart's state
            guard let idx = flyingHearts.firstIndex(where: { $0.id == heartID }) else {
                timer.invalidate()
                activeTimers.removeValue(forKey: heartID)
                return
            }

            if elapsed < scaleInDuration {
                // Phase 1: scale the heart in at the start position
                let t = elapsed / scaleInDuration
                flyingHearts[idx].scale = CGFloat(t)
                flyingHearts[idx].progress = 0
            } else {
                // Phase 2: move along the path bottom → top
                flyingHearts[idx].scale = 1
                let linearProgress = (elapsed - scaleInDuration)
                    / heartAnimationDuration
                flyingHearts[idx].progress = easeInOut(linearProgress)
            }
        }

        activeTimers[heartID] = timer
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
