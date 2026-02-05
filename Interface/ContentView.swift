//
//  ContentView.swift
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

import SwiftUI


struct RippleModifier: ViewModifier {
    var origin: CGPoint
    var elapsedTime: TimeInterval
    var duration: TimeInterval
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double
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
            .float(speed)
        )
        
        let maxSampleOffset = maxSampleOffset
        let elasedTime = elapsedTime
        let duration = duration
        
        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset : maxSampleOffset,
                isEnabled: 0 < elapsedTime && elasedTime < duration
            )
        }
    }
}

struct RippleEffect<T: Equatable>: ViewModifier {
    var origin: CGPoint
    var trigger: T
    var duration: TimeInterval
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double
    
    init(at origin: CGPoint, trigger: T, duration: TimeInterval = 3, amplitude: Double = 12, frequency: Double = 15, decay: Double = 8, speed: Double = 1200) {
        self.origin = origin
        self.trigger = trigger
        self.duration = duration
        self.amplitude = amplitude
        self.frequency = frequency
        self.decay = decay
        self.speed = speed
    }
    
    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration
        let amplitude = amplitude
        let frequency = frequency
        let decay = decay
        let speed = speed
        
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
                speed: speed
            ))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}


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

struct ContentView: View {
    @State private var origin: CGPoint = .zero
    @State private var counter: Int = 0
    @State private var amplitude: Double = 12
    @State private var frequency: Double = 15
    @State private var decay: Double = 8
    @State private var speed: Double = 1200
    @State private var duration: Double = 3
    @State private var contentText: String = "In the Slack thread, team members are discussing the development of a new part-payment feature. They emphasize the need for a comprehensive solution that allows merchants to provide flexible payment options, making purchases more manageable for consumers. The conversation also highlights the importance of a seamless user experience and smooth integration with current workflows. The team aims to have this functionality ready for deployment by December 10th."

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Shader controls — compact grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ripple shader")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 12) {
                            ControlCell(label: "Amplitude", value: amplitude, format: "%.1f") {
                                Slider(value: $amplitude, in: 1...40, step: 1)
                            }
                            ControlCell(label: "Frequency", value: frequency, format: "%.1f") {
                                Slider(value: $frequency, in: 1...40, step: 0.5)
                            }
                            ControlCell(label: "Decay", value: decay, format: "%.1f") {
                                Slider(value: $decay, in: 0.5...25, step: 0.5)
                            }
                            ControlCell(label: "Speed", value: speed, format: "%.0f") {
                                Slider(value: $speed, in: 200...3000, step: 100)
                            }
                            ControlCell(label: "Duration", value: duration, format: "%.1f s") {
                                Slider(value: $duration, in: 1...6, step: 0.5)
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )

                    // Tap target
                    Text(contentText)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 4)
                        .modifier(RippleEffect(at: origin, trigger: counter, duration: duration, amplitude: amplitude, frequency: frequency, decay: decay, speed: speed))
                        .onTapGesture(count: 2) { location in
                            origin = location
                            counter += 1
                        }

                    // Edit text content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit content")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextEditor(text: $contentText)
                            .frame(minHeight: 100, maxHeight: 160)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
