//
//  PinchSummaryView.swift
//  Interface
//
//  Created by Harsh Sharma on 06/02/26.
//

import SwiftUI

// MARK: - Root View

struct PinchSummaryView: View {
    enum Mode {
        case chat
        case summary
    }
    
    @State private var mode: Mode = .chat
    @State private var transitionProgress: CGFloat = 0 // 0 → 1
    @GestureState private var pinchScale: CGFloat = 1
    
    private let collapseThreshold: CGFloat = 0.75
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // AI Summary lives underneath
                AISummaryView()
                    .opacity(transitionProgress)
                
                ChatSurface(isScrollEnabled: mode == .chat && transitionProgress == 0)
                    .modifier(
                        ChatTransform(
                            progress: transitionProgress,
                            screenSize: geo.size
                        )
                    )
                    .contentShape(Rectangle())
                    .modifier(PinchGestureModifier(
                        gesture: pinchGesture,
                        isEnabled: mode == .chat
                    ))
                    .onTapGesture {
                        if mode == .summary {
                            expand()
                        }
                    }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: transitionProgress)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Pinch Gesture Logic

extension PinchSummaryView {
    
    var pinchGesture: some Gesture {
        MagnifyGesture()
            .updating($pinchScale) { value, state, _ in
                state = value.magnification
            }
            .onChanged { value in
                guard mode == .chat else { return }
                
                // Pinch down (magnification < 1) should collapse
                let normalized = max(0, min(1, 1 - value.magnification))
                transitionProgress = normalized
            }
            .onEnded { value in
                // If pinched down enough (magnification < threshold), collapse
                if value.magnification < collapseThreshold {
                    collapse()
                } else {
                    reset()
                }
            }
    }
    
    private func collapse() {
        mode = .summary
        transitionProgress = 1
    }
    
    private func expand() {
        mode = .chat
        transitionProgress = 0
    }
    
    private func reset() {
        transitionProgress = 0
    }
}

// MARK: - Chat Surface

struct ChatSurface: View {
    let isScrollEnabled: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<40) { i in
                    Text("Message \(i)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .scrollDisabled(!isScrollEnabled)
        .background(Color.white)
    }
}

// MARK: - Pinch Gesture Modifier

struct PinchGestureModifier<G: Gesture>: ViewModifier {
    let gesture: G
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        if isEnabled {
            content.highPriorityGesture(gesture)
        } else {
            content
        }
    }
}

// MARK: - Chat Transform Modifier

struct ChatTransform: ViewModifier {
    let progress: CGFloat   // 0 → 1
    let screenSize: CGSize
    
    func body(content: Content) -> some View {
        let collapsedSize: CGFloat = 600 // diameter (300 radius)
        let width = lerp(screenSize.width, collapsedSize, progress)
        let height = lerp(screenSize.height, collapsedSize, progress)
        
        let cornerRadius = lerp(0, collapsedSize / 2, progress)
        
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2
        
        return content
            .frame(width: width, height: height)
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .position(x: centerX, y: centerY)
            .shadow(radius: lerp(0, 20, progress))
    }
    
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }
}

// MARK: - AI Summary View

struct AISummaryView: View {
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("AI Summary goes here…")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // Placeholder summary content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Points:")
                            .font(.headline)
                        Text("• Summary point 1")
                        Text("• Summary point 2")
                        Text("• Summary point 3")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 100) // Space for input box
            }
            
            // Input box at the bottom
            HStack {
                TextField("Ask a follow-up…", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button(action: {
                    // Handle send action
                    inputText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
        }
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    PinchSummaryView()
}
