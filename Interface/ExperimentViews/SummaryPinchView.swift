//
//  SummaryPinchView.swift
//  Interface
//

import SwiftUI

struct SummaryPinchView: View {

    // MARK: - Gesture + Transition State
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var isCollapsed = false

    // Velocity tracking
    @State private var lastGestureTime: Date = .now
    @State private var lastGestureValue: CGFloat = 1
    @State private var velocity: CGFloat = 0 // units per second (negative = pinching in)

    // Haptic threshold tracking
    @State private var hasTriggeredMidHaptic = false

    // MARK: - Constants
    private let collapseThreshold: CGFloat = 0.6
    private let minScale: CGFloat = 0.35
    private let circleSize: CGFloat = 72

    // Resistance curve: higher = more resistance early on
    // At exponent > 1 the first portion of the pinch feels "stiffer"
    private let resistanceExponent: CGFloat = 2.8

    // Velocity threshold (units/sec) – a fast inward pinch collapses immediately
    private let velocityCollapseThreshold: CGFloat = -3.5

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MorphingContentView(
                    scale: scale,
                    isCollapsed: isCollapsed,
                    circleSize: circleSize,
                    screenSize: geometry.size
                )
                .onTapGesture {
                    if isCollapsed {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                            isCollapsed = false
                            scale = 1
                        }
//                        haptic(.medium)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .simultaneousGesture(pinchGesture)
        }
        .ignoresSafeArea()
        .animation(
            .spring(response: 0.4, dampingFraction: 0.82),
            value: isCollapsed
        )
        .navigationTitle("Summariser")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                isCollapsed = !isCollapsed
            } label: {
                Label("Toggle", systemImage: "arrow.2.circlepath")
            }
        }

    }

    // MARK: - Non-linear Resistance
    /// Maps a raw linear 0→1 progress to a resisted 0→1 progress.
    /// Early values are compressed (feel heavy); later values open up.
    private func applyResistance(to linearProgress: CGFloat) -> CGFloat {
        let clamped = max(0, min(1, linearProgress))
        // pow(x, exponent) where exponent > 1 flattens the curve near 0
        return pow(clamped, resistanceExponent)
    }

    /// Converts a raw gesture magnification value into a resisted scale.
    /// `rawScale` goes from 1 (no pinch) towards 0 (fully pinched).
    private func resistedScale(from rawScale: CGFloat) -> CGFloat {
        guard rawScale < 1 else { return min(rawScale, 1.05) } // slight clamp for pinch-out

        // linearProgress: 0 (no pinch) → 1 (fully pinched to minScale)
        let linearProgress = (1 - rawScale) / (1 - minScale)
        let resistedProgress = applyResistance(to: linearProgress)
        return max(minScale, 1 - resistedProgress * (1 - minScale))
    }

    // MARK: - Haptics
    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    // MARK: - Pinch Gesture
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let now = Date.now
                let delta = value / lastScale
                lastScale = value

                // --- Velocity calculation ---
                let dt = now.timeIntervalSince(lastGestureTime)
                if dt > 0.001 { // avoid division by near-zero
                    let instantVelocity = (value - lastGestureValue) / dt
                    // Smooth with exponential moving average
                    velocity = velocity * 0.3 + instantVelocity * 0.7
                }
                lastGestureTime = now
                lastGestureValue = value

                // --- Compute raw (unresisted) target ---
                let rawTarget = scale * delta

                // --- Apply non-linear resistance ---
                let newScale: CGFloat
                if rawTarget < 1 {
                    // Pinching inward: apply resistance
                    newScale = resistedScale(from: rawTarget)
                } else {
                    // Pinching outward (expanding back): linear, clamped to 1
                    newScale = min(1, rawTarget)
                }

                scale = max(minScale, newScale)

                // --- Mid-pinch haptic when crossing the collapse region ---
                let progress = (1 - scale) / (1 - minScale)
                if progress > 0.5 && !hasTriggeredMidHaptic {
                    hasTriggeredMidHaptic = true
//                    haptic(.light)
                } else if progress < 0.3 {
                    hasTriggeredMidHaptic = false
                }

                // --- Fast-velocity immediate collapse ---
                if velocity < velocityCollapseThreshold && !isCollapsed {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isCollapsed = true
                        scale = minScale
                    }
//                    haptic(.heavy)
                }
            }
            .onEnded { _ in
                lastScale = 1
                lastGestureValue = 1
                lastGestureTime = .now
                hasTriggeredMidHaptic = false

                let endVelocity = velocity
                velocity = 0

                // If the gesture ended with significant inward velocity, lower the
                // threshold so a moderately fast pinch still collapses.
                let effectiveThreshold: CGFloat
                if endVelocity < -1.5 {
                    // Lerp threshold down based on velocity (faster → easier collapse)
                    let velocityFactor = min(1, (abs(endVelocity) - 1.5) / 3.0)
                    effectiveThreshold = collapseThreshold + (1.0 - collapseThreshold) * velocityFactor * 0.4
                } else {
                    effectiveThreshold = collapseThreshold
                }

                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    if scale < effectiveThreshold {
                        isCollapsed = true
                        scale = minScale
//                        haptic(.heavy)
                    } else {
                        isCollapsed = false
                        scale = 1
                    }
                }
            }
    }
}

// MARK: - Morphing Content View
private struct MorphingContentView: View {
    let scale: CGFloat
    let isCollapsed: Bool
    let circleSize: CGFloat
    let screenSize: CGSize
    
    // Progress from expanded (0) to collapsed (1)
    private var morphProgress: CGFloat {
        if isCollapsed {
            return 1
        } else {
            // Map scale from 1.0 → 0.35 to progress 0 → 1
            return max(0, min(1, (1 - scale) / 0.65))
        }
    }
    
    // Interpolate corner radius
    private var cornerRadius: CGFloat {
        let maxRadius = min(screenSize.width, screenSize.height) / 2
        return morphProgress * maxRadius
    }
    
    // Interpolate size
    private var morphSize: CGSize {
        let width = screenSize.width - (screenSize.width - circleSize) * morphProgress
        let height = screenSize.height - (screenSize.height - circleSize) * morphProgress
        return CGSize(width: width, height: height)
    }
    
    var body: some View {
        ZStack {
            // Background that morphs
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    isCollapsed
                        ? Color.black.opacity(0.9)
                        : Color.blue.opacity(0.15)
                )
            
            // Content that fades/switches
            if isCollapsed {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .transition(.opacity)
            } else {
                ScrollView {
                    Text(longText)
                        .font(.body)
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .safeAreaPadding(.top, 60)
                }
                .opacity(1 - morphProgress)
                .transition(.opacity)
            }
        }
        .frame(width: morphSize.width, height: morphSize.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip overflow
        .scaleEffect(isCollapsed ? 1 : scale)
    }
}

// MARK: - Very Long Text (≈4×)
private let longText = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

---

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

---

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

---

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
"""

#Preview {
    NavigationStack {
        SummaryPinchView()
    }
}
