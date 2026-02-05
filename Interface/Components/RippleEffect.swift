//
//  RippleEffect.swift
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

import SwiftUI

/// Applies the ripple layer effect for a single frame (used internally by `RippleEffect`).
struct RippleModifier: ViewModifier {
    var origin: CGPoint
    var elapsedTime: TimeInterval
    var duration: TimeInterval
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double
    var redIntensity: Double
    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsedTime),
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed),
            .float(redIntensity)
        )

        let maxSampleOffset = maxSampleOffset
        let elapsedTime = elapsedTime
        let duration = duration

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }
}

/// A view modifier that applies a ripple effect from a given origin when `trigger` changes.
/// Use `.modifier(RippleEffect(at:origin, trigger: value, ...))` on any view to get the effect.
public struct RippleEffect<T: Equatable>: ViewModifier {
    public var origin: CGPoint
    public var trigger: T
    public var duration: TimeInterval
    public var amplitude: Double
    public var frequency: Double
    public var decay: Double
    public var speed: Double
    public var redIntensity: Double

    public init(
        at origin: CGPoint,
        trigger: T,
        duration: TimeInterval = 3,
        amplitude: Double = 12,
        frequency: Double = 15,
        decay: Double = 8,
        speed: Double = 1200,
        redIntensity: Double = 1
    ) {
        self.origin = origin
        self.trigger = trigger
        self.duration = duration
        self.amplitude = amplitude
        self.frequency = frequency
        self.decay = decay
        self.speed = speed
        self.redIntensity = redIntensity
    }

    public func body(content: Content) -> some View {
        let origin = origin
        let duration = duration
        let amplitude = amplitude
        let frequency = frequency
        let decay = decay
        let speed = speed
        let redIntensity = redIntensity

        content.keyframeAnimator(
            initialValue: 0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(RippleModifier(
                origin: origin,
                elapsedTime: elapsedTime,
                duration: duration,
                amplitude: amplitude,
                frequency: frequency,
                decay: decay,
                speed: speed,
                redIntensity: redIntensity
            ))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}

// MARK: - View extension

public extension View {
    /// Applies a ripple effect from the given origin whenever `trigger` changes.
    func rippleEffect<T: Equatable>(
        at origin: CGPoint,
        trigger: T,
        duration: TimeInterval = 3,
        amplitude: Double = 12,
        frequency: Double = 15,
        decay: Double = 8,
        speed: Double = 1200,
        redIntensity: Double = 1
    ) -> some View {
        modifier(RippleEffect(
            at: origin,
            trigger: trigger,
            duration: duration,
            amplitude: amplitude,
            frequency: frequency,
            decay: decay,
            speed: speed,
            redIntensity: redIntensity
        ))
    }
}
