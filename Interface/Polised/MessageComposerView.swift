//
//  MessageComposerView.swift
//  Interface
//
//  Created by Harsh Sharma on 06/02/26.
//

import SwiftUI

struct MessageComposerView: View {
    @State private var likeCount: Int = 0
    @State private var showMessageSheet: Bool = false
    @State private var messageSide: MessageComposerWrapper.Side = .left
    @State private var message: String = """
    We’re facing persistent payment failures from several customers, who are encountering transaction timeouts and vague error messages. This is hurting our sales performance. Can the payment team look into this urgently? Much appreciated!
    """

    // Ripple effect
    @State private var amplitude: Double = 12
    @State private var frequency: Double = 15
    @State private var decay: Double = 8
    @State private var speed: Double = 1200
    @State private var duration: Double = 3
    @State private var redIntensity: Double = 0.01

    // Heart animation
    @State private var heartAnimationDuration: Double = 0.6
    @State private var heartScaleInDuration: Double = 0.15

    private let gridColumns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top: flexible area with MessageComposerWrapper centered
            VStack {
                MessageComposerWrapper(
                    text: message,
                    likeCount: $likeCount,
                    side: messageSide,
                    amplitude: amplitude,
                    frequency: frequency,
                    decay: decay,
                    speed: speed,
                    duration: duration,
                    redIntensity: redIntensity,
                    heartAnimationDuration: heartAnimationDuration,
                    heartScaleInDuration: heartScaleInDuration
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Alignment controls
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        messageSide = .left
                    }
                } label: {
                    Label("Left", systemImage: "arrow.left")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                .glassEffect(.regular)

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        messageSide = .right
                    }
                } label: {
                    Label("Right", systemImage: "arrow.right")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                .glassEffect(.regular)
            }
            .padding(.bottom, 12)

            // Bottom: effect controls grid
            LazyVGrid(columns: gridColumns, spacing: 8) {
                GridSliderCell(label: "Amp", value: $amplitude, range: 1...40, format: "%.0f")
                GridSliderCell(label: "Freq", value: $frequency, range: 1...40, format: "%.0f")
                GridSliderCell(label: "Decay", value: $decay, range: 0.5...25, format: "%.1f")
                GridSliderCell(label: "Speed", value: $speed, range: 200...3000, step: 100, format: "%.0f")
                GridSliderCell(label: "Dur", value: $duration, range: 1...20, format: "%.1f")
                GridSliderCell(label: "Red", value: $redIntensity, range: 0...2, format: "%.2f")
                GridSliderCell(label: "Heart Dur", value: $heartAnimationDuration, range: 0.2...2, format: "%.2f")
                GridSliderCell(label: "ScaleIn", value: $heartScaleInDuration, range: 0.05...0.5, step: 0.01, format: "%.2f")
            }
            .padding(10)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Composer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button{
                    likeCount = 0
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                Button {
                    showMessageSheet = true
                } label: {
                    Label("Edit message", systemImage: "pencil.line")
                }
            }
        }
        .sheet(isPresented: $showMessageSheet) {
            MessageEditSheet(message: $message)
        }
    }
}

// MARK: - Message edit bottom sheet

private struct MessageEditSheet: View {
    @Binding var message: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TextEditor(text: $message)
                .font(.body)
                .padding()
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Edit message")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - Grid slider cell (compact, for in-view grid)

private struct GridSliderCell: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.1
    let format: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 2)
                Text(String(format: format, value))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

#Preview {
    NavigationStack {
        MessageComposerView()
    }
}
