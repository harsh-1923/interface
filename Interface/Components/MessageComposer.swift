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
    var opacity: Double = 1.0
    /// Whether the timer has started driving this heart; hidden until true
    var isActive: Bool = false
    /// Whether this heart should trigger the like count increment
    var shouldIncrementLike: Bool = false
    /// Whether the like increment has already fired for this heart
    var didIncrementLike: Bool = false
}

// MARK: - MessageComposer Component

struct MessageComposer: View {
    let text: String
    @Binding var likeCount: Int

    // Ripple effect (double-tap)
    var amplitude: Double = 12
    var frequency: Double = 15
    var decay: Double = 8
    var speed: Double = 1200
    var duration: Double = 3
    var redIntensity: Double = 0.01

    // Heart path animation
    var heartAnimationDuration: Double = 0.6
    var heartScaleInDuration: Double = 0.15
    var heartStaggerDelay: Double = 0.12

    @State private var origin: CGPoint = .zero
    @State private var counter: Int = 0

    // Heart path animation state — supports multiple simultaneous hearts
    @State private var flyingHearts: [FlyingHeart] = []
    @State private var activeTimers: [UUID: Timer] = [:]

    var body: some View {
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
                        let size = geometry.size
                        let path = straightPath(in: size)

                        ForEach(flyingHearts) { heart in
                            let fadeOut = heart.progress > 0.75
                                ? 1.0 - ((heart.progress - 0.75) / 0.25)
                                : 1.0

                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                                .opacity(heart.isActive ? heart.opacity * fadeOut : 0)
                                .scaleEffect(heart.scale * fadeOut)
                                .position(
                                    positionOnPath(
                                        path: path,
                                        progress: heart.progress,
                                        in: size
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

            if likeCount > 0 {
                LikeCountPill(count: $likeCount)
                    .offset(x: 8, y: -18)
            }
        }
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

    /// The start point of the flight path (bottom-right of the bubble)
    private func pathStartPoint(in size: CGSize) -> CGPoint {
        let inset: CGFloat = 16
        return CGPoint(x: size.width - inset, y: size.height)
    }

    /// Get the position at a given progress (0...1) along a path
    private func positionOnPath(path: Path, progress: CGFloat, in size: CGSize) -> CGPoint {
        let t = max(0, min(1, progress))
        let start = pathStartPoint(in: size)
        guard t > 0 else { return start }
        let trimmed = path.trimmedPath(from: 0, to: t)
        return trimmed.currentPoint ?? start
    }

    // MARK: - Animation

    private func easeInOut(_ t: Double) -> CGFloat {
        CGFloat(t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2)
    }

    /// Spawn three staggered hearts with reducing opacities (100%, 70%, 50%)
    private func spawnHeartAnimation() {
        let opacities: [Double] = [1.0, 0.7, 0.5]

        for index in opacities.indices {
            let delay = Double(index) * heartStaggerDelay
            let opacity = opacities[index]
            let isFirst = index == 0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                spawnSingleHeart(opacity: opacity, incrementLike: isFirst)
            }
        }
    }

    /// Spawn a single heart with the given opacity along the flight path
    private func spawnSingleHeart(opacity: Double, incrementLike: Bool) {
        var heart = FlyingHeart(id: UUID())
        heart.opacity = opacity
        heart.shouldIncrementLike = incrementLike
        flyingHearts.append(heart)

        let startTime = Date()
        let frameRate: TimeInterval = 1.0 / 60.0
        let totalDuration = heartScaleInDuration + heartAnimationDuration
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
                return
            }

            // Find and update this heart's state
            guard let idx = flyingHearts.firstIndex(where: { $0.id == heartID }) else {
                timer.invalidate()
                activeTimers.removeValue(forKey: heartID)
                return
            }

            // Mark active on first tick so the view becomes visible
            if !flyingHearts[idx].isActive {
                flyingHearts[idx].isActive = true
            }

            if elapsed < heartScaleInDuration {
                // Phase 1: scale the heart in at the start position
                let t = elapsed / heartScaleInDuration
                flyingHearts[idx].scale = CGFloat(t)
                flyingHearts[idx].progress = 0
            } else {
                // Phase 2: move along the path bottom → top
                flyingHearts[idx].scale = 1
                let linearProgress = (elapsed - heartScaleInDuration)
                    / heartAnimationDuration
                flyingHearts[idx].progress = easeInOut(linearProgress)

                // Increment like count as soon as fade-out begins
                if flyingHearts[idx].progress > 0.75,
                   flyingHearts[idx].shouldIncrementLike,
                   !flyingHearts[idx].didIncrementLike {
                    flyingHearts[idx].didIncrementLike = true
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        likeCount += 1
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
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
        .transition(
            .asymmetric(
                insertion:
                        .scale(scale: 0, anchor: .bottom)
                        .combined(with: .opacity),
                removal: .scale(scale: 0, anchor: .bottom)
                    .combined(with: .opacity)
            )
        )
    } 
}

#Preview {
    MessageComposer(
        text: "Hello! This is a reusable message composer component.",
        likeCount: .constant(3)
    )
    .padding(.horizontal)
}
