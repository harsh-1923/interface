//
//  MessageRippleView.swift
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

import SwiftUI

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

struct MessageRippleView: View {
    @State private var origin: CGPoint = .zero
    @State private var counter: Int = 0
    @State private var amplitude: Double = 12
    @State private var frequency: Double = 15
    @State private var decay: Double = 8
    @State private var speed: Double = 1200
    @State private var duration: Double = 3
    @State private var redIntensity: Double = 0.3
    @State private var contentText: String = "I'm still encountering payment failures with multiple customers. Transactions are timing out, and some users are getting generic error messages. This is impacting sales. Can the payment team investigate ASAP?"
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Shader controls — compact grid
                    VStack(alignment: .leading, spacing: 10) {
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
                                Slider(value: $duration, in: 1...20, step: 0.5)
                            }
                            ControlCell(label: "Red intensity", value: redIntensity, format: "%.2f") {
                                Slider(value: $redIntensity, in: 0...2, step: 0.05)
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
                        .foregroundStyle(Color(.label))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                        .modifier(RippleEffect(at: origin, trigger: counter, duration: duration, amplitude: amplitude, frequency: frequency, decay: decay, speed: speed, redIntensity: redIntensity))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.primary.opacity(0.08), radius: 10, x: 0, y: 4)
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
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    NavigationStack {
        MessageRippleView()
    }
}

