//
//  PathAnimationView.swift
//  Interface
//

import SwiftUI

// MARK: - Control Cell

private struct ControlCell<Content: View>: View {
    let label: String
    let value: Double
    let format: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 4)
                Text(String(format: format, value))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            content()
        }
    }
}

// MARK: - Message Side

enum MessageSide {
    case left   // Messages from others
    case right  // Messages sent by current user
    
    var alignment: Alignment {
        switch self {
        case .left: return .leading
        case .right: return .trailing
        }
    }
    
    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .left: return .leading
        case .right: return .trailing
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .left: return Color(.secondarySystemBackground)
        case .right: return Color.blue
        }
    }
    
    var textColor: Color {
        switch self {
        case .left: return .primary
        case .right: return .white
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let text: String
    let side: MessageSide
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12
    var maxWidthRatio: CGFloat = 0.75
    
    var body: some View {
        // Full-width container
        HStack {
            if side == .right {
                Spacer(minLength: 0)
            }
            
            // Child container with max-width 75%, rounded corners and background
            Text(text)
                .font(.default)
                .foregroundStyle(side.textColor)
                .padding(padding)
                .background(side.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .frame(maxWidth: .infinity, alignment: side.alignment)
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * maxWidthRatio
                }
            
            if side == .left {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Message Bubble with Effects

/// A message bubble with ripple effect and path animation attached to the inner container
struct MessageBubbleWithEffects: View {
    let text: String
    let side: MessageSide
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12
    var maxWidthRatio: CGFloat = 0.75
    
    // Ripple effect parameters
    var rippleOrigin: CGPoint = .zero
    var rippleTrigger: Int = 0
    var rippleDuration: Double = 3
    var rippleAmplitude: Double = 12
    var rippleFrequency: Double = 15
    var rippleDecay: Double = 8
    var rippleSpeed: Double = 1200
    var rippleRedIntensity: Double = 0.3
    
    // Path animation parameters
    var curvature: CGFloat = 0.35
    var showHeart: Bool = false
    var heartScale: CGFloat = 0
    var animationProgress: CGFloat = 0
    
    var body: some View {
        // Full-width container
        HStack {
            if side == .right {
                Spacer(minLength: 0)
            }
            
            // Child container with effects
            innerBubble
                .modifier(RippleEffect(
                    at: rippleOrigin,
                    trigger: rippleTrigger,
                    duration: rippleDuration,
                    amplitude: rippleAmplitude,
                    frequency: rippleFrequency,
                    decay: rippleDecay,
                    speed: rippleSpeed,
                    redIntensity: rippleRedIntensity
                ))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay {
                    GeometryReader { geometry in
                        let path = cornerPath(in: geometry.size, curvature: curvature, side: side)
                        
                        ZStack(alignment: .topLeading) {
                            path
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                                .foregroundStyle(.red.opacity(0.35))
                            
                            if showHeart {
                                Image(systemName: "heart.fill")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                    .scaleEffect(heartScale)
                                    .position(getPositionOnPath(path: path, progress: animationProgress))
                            }
                        }
                    }
                }
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * maxWidthRatio
                }
            
            if side == .left {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var innerBubble: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(side.textColor)
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: side.alignment)
            .background(side.backgroundColor)
    }
    
    /// Path from bottom edge to top edge.
    /// For left-aligned bubbles (from others): path is on the RIGHT side (right bottom to right top).
    /// For right-aligned bubbles (from me): path is on the LEFT side (left bottom to left top).
    private func cornerPath(in size: CGSize, curvature: CGFloat, side: MessageSide) -> Path {
        let horizontalInset: CGFloat = 16
        let w = size.width
        let h = size.height
        let maxCurveOffset = min(120, (w - horizontalInset * 2) * 0.5)
        
        let start: CGPoint
        let end: CGPoint
        let control: CGPoint
        
        switch side {
        case .left:
            // Curve on the RIGHT side of the bubble
            start = CGPoint(x: w - horizontalInset, y: h)
            end = CGPoint(x: w - horizontalInset, y: 0)
            let controlX = w - horizontalInset - (curvature * maxCurveOffset)
            control = CGPoint(x: controlX, y: h / 2)
        case .right:
            // Curve on the LEFT side of the bubble
            start = CGPoint(x: horizontalInset, y: h)
            end = CGPoint(x: horizontalInset, y: 0)
            let controlX = horizontalInset + (curvature * maxCurveOffset)
            control = CGPoint(x: controlX, y: h / 2)
        }
        
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
    
    private func getPositionOnPath(path: Path, progress: CGFloat) -> CGPoint {
        let t = max(0, min(1, progress))
        guard t > 0 else {
            return path.trimmedPath(from: 0, to: 0.001).currentPoint ?? path.currentPoint ?? .zero
        }
        let trimmed = path.trimmedPath(from: 0, to: t)
        return trimmed.currentPoint ?? path.currentPoint ?? .zero
    }
}

// MARK: - Sample message lengths

private enum MessageLength: String, CaseIterable {
    case short = "Short"
    case med = "Med"
    case long = "Long"

    static func text(for length: MessageLength) -> String {
        switch length {
        case .short:
            return "Hi there!"
        case .med:
            return "Your message here.\n\nThis area shows the text with padding and rounded corners."
        case .long:
            return "Your message here.\n\nThis area shows the text with padding and rounded corners. Tap Start to move the heart along the path from bottom-right to top-right. Change curvature and message length with the controls below."
        }
    }
}

// MARK: - Path Animation Demo

struct PathAnimationDemo: View {
    @State private var displayText: String = MessageLength.text(for: .long)
    @State private var messageSide: MessageSide = .right
    @State private var isAnimating = false
    @State private var showHeart = false
    @State private var animationProgress: CGFloat = 0
    @State private var heartScale: CGFloat = 0
    @State private var duration: Double = 0.3
    @State private var curvature: CGFloat = 0.35
    @State private var animationTimer: Timer?
    private let scaleInDuration: Double = 0.2
    
    // Ripple effect state
    @State private var rippleOrigin: CGPoint = .zero
    @State private var rippleCounter: Int = 0
    @State private var rippleAmplitude: Double = 12
    @State private var rippleFrequency: Double = 15
    @State private var rippleDecay: Double = 8
    @State private var rippleSpeed: Double = 1200
    @State private var rippleDuration: Double = 3
    @State private var rippleRedIntensity: Double = 0.3

    var body: some View {
        VStack(spacing: 0) {
            // 1. Demo container: full width, all available height, no bg or border
            Group {
                MessageBubbleWithEffects(
                    text: displayText,
                    side: messageSide,
                    rippleOrigin: rippleOrigin,
                    rippleTrigger: rippleCounter,
                    rippleDuration: rippleDuration,
                    rippleAmplitude: rippleAmplitude,
                    rippleFrequency: rippleFrequency,
                    rippleDecay: rippleDecay,
                    rippleSpeed: rippleSpeed,
                    rippleRedIntensity: rippleRedIntensity,
                    curvature: curvature,
                    showHeart: showHeart,
                    heartScale: heartScale,
                    animationProgress: animationProgress
                )
                .padding(.horizontal)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { location in
                    rippleOrigin = location
                    rippleCounter += 1
                    startAnimation()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 2. Controls container: compact, no scroll
            VStack(spacing: 10) {
                // Side + message length row
                HStack(spacing: 6) {
                    Button { messageSide = .left } label: {
                        Label("Left", systemImage: "arrow.left")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(messageSide == .left ? .white : .primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    .glassEffect(.regular.tint(messageSide == .left ? .blue : .clear))

                    Button { messageSide = .right } label: {
                        Label("Right", systemImage: "arrow.right")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(messageSide == .right ? .white : .primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    .glassEffect(.regular.tint(messageSide == .right ? .blue : .clear))

                    Spacer(minLength: 2)

                    ForEach(MessageLength.allCases, id: \.self) { length in
                        Button { displayText = MessageLength.text(for: length) } label: {
                            Text(length.rawValue)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                        }
                        .glassEffect(.regular)
                    }
                }

                // Path + Ripple in one grid (compact)
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 8) {
                    ControlCell(label: "Curvature", value: curvature * 100, format: "%.0f%%") {
                        Slider(value: $curvature, in: 0...1, step: 0.05)
                    }
                    ControlCell(label: "Duration", value: duration, format: "%.1f s") {
                        Slider(value: $duration, in: 0.0...5.0, step: 0.1)
                    }
                    ControlCell(label: "Amplitude", value: rippleAmplitude, format: "%.1f") {
                        Slider(value: $rippleAmplitude, in: 1...40, step: 1)
                    }
                    ControlCell(label: "Freq", value: rippleFrequency, format: "%.1f") {
                        Slider(value: $rippleFrequency, in: 1...40, step: 0.5)
                    }
                    ControlCell(label: "Decay", value: rippleDecay, format: "%.1f") {
                        Slider(value: $rippleDecay, in: 0.5...25, step: 0.5)
                    }
                    ControlCell(label: "Speed", value: rippleSpeed, format: "%.0f") {
                        Slider(value: $rippleSpeed, in: 200...3000, step: 100)
                    }
                    ControlCell(label: "Ripple Dur", value: rippleDuration, format: "%.1f s") {
                        Slider(value: $rippleDuration, in: 1...20, step: 0.5)
                    }
                    ControlCell(label: "Red", value: rippleRedIntensity, format: "%.2f") {
                        Slider(value: $rippleRedIntensity, in: 0...2, step: 0.05)
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))

                Button {
                    startAnimation()
                } label: {
                    HStack {
                        Image(systemName: isAnimating ? "stop.fill" : "play.fill")
                        Text(isAnimating ? "Animating..." : "Start Animation")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .glassEffect(.regular.tint(isAnimating ? .gray : .blue))
                .disabled(isAnimating)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Path Animation")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            animationTimer?.invalidate()
        }
    }

    func easeInOut(_ t: Double) -> CGFloat {
        CGFloat(t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2)
    }

    func startAnimation() {
        isAnimating = true
        showHeart = true
        animationProgress = 0
        heartScale = 0

        let startTime = Date()
        let frameRate: TimeInterval = 1.0 / 60.0
        let totalDuration = scaleInDuration + duration

        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { [self] timer in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if elapsed >= totalDuration {
                // Animation complete - hide heart immediately when it reaches the top
                timer.invalidate()
                animationTimer = nil
                showHeart = false
                isAnimating = false
                return
            }

            if elapsed < scaleInDuration {
                // Phase 1: scale in (heart appears at bottom and grows to full size)
                let t = elapsed / scaleInDuration
                heartScale = CGFloat(t)
                animationProgress = 0
            } else {
                // Phase 2: move along path from bottom to top
                heartScale = 1
                let linearProgress = (elapsed - scaleInDuration) / duration
                animationProgress = easeInOut(linearProgress)
            }
        }
    }

    func resetAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        animationProgress = 0
        heartScale = 0
        showHeart = false
        isAnimating = false
    }
}

#Preview {
    NavigationStack {
        PathAnimationDemo()
    }
}
