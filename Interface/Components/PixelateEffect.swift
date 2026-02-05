//
//  PixelateEffect.swift
//  Interface
//

import SwiftUI

/// A view modifier that pixelates the view by dividing it into blocks of a given size.
/// Apply to any view with `.pixelate(blockSize: 8)` or `.modifier(PixelateEffect(blockSize: 8))`.
public struct PixelateEffect: ViewModifier {
    /// Size of each block in points (1 = no pixelation, larger = more blocky).
    public var blockSize: CGFloat

    public init(blockSize: CGFloat = 8) {
        self.blockSize = max(1, blockSize)
    }

    public func body(content: Content) -> some View {
        let blockSize = blockSize
        let maxSampleOffset = CGSize(width: blockSize, height: blockSize)

        content.visualEffect { view, _ in
            view.layerEffect(
                ShaderLibrary.Pixelate(.float(Float(blockSize))),
                maxSampleOffset: maxSampleOffset,
                isEnabled: blockSize > 1
            )
        }
    }
}

// MARK: - Wave-based pixelation (left-to-right sweep)

/// Pixelation that sweeps from left to right: left edge first, then next column and so on.
public struct PixelateWaveEffect: ViewModifier {
    /// 0 = all normal, 1 = all pixelated. Animate 0→1 to pixelate, 1→0 to depixelate.
    public var progress: Double
    /// Width of the layer in points (used to normalize the sweep).
    public var layerWidth: CGFloat
    /// Width of the soft edge in normalized space (0–1), e.g. 0.08.
    public var bandSoftness: CGFloat
    public var maxBlockSize: CGFloat

    public init(
        progress: Double,
        layerWidth: CGFloat,
        bandSoftness: CGFloat = 0.08,
        maxBlockSize: CGFloat = 12
    ) {
        self.progress = progress
        self.layerWidth = max(1, layerWidth)
        self.bandSoftness = bandSoftness
        self.maxBlockSize = max(1, maxBlockSize)
    }

    public func body(content: Content) -> some View {
        let maxSampleOffset = CGSize(width: maxBlockSize, height: maxBlockSize)

        content.visualEffect { view, _ in
            view.layerEffect(
                ShaderLibrary.PixelateWave(
                    .float(Float(progress)),
                    .float(Float(layerWidth)),
                    .float(Float(bandSoftness)),
                    .float(Float(maxBlockSize))
                ),
                maxSampleOffset: maxSampleOffset,
                isEnabled: true
            )
        }
    }
}

// MARK: - View extensions

public extension View {
    /// Pixelates the view by dividing it into blocks. Block size is in points.
    /// - Parameter blockSize: Width and height of each block (1 = no effect, e.g. 8 or 16 for strong pixelation).
    func pixelate(blockSize: CGFloat = 8) -> some View {
        modifier(PixelateEffect(blockSize: blockSize))
    }

    /// Pixelates with a left-to-right sweep. Pass `layerWidth` (e.g. from GeometryReader). Animate `progress` 0→1 to pixelate, 1→0 to depixelate.
    func pixelateWave(
        progress: Double,
        layerWidth: CGFloat,
        bandSoftness: CGFloat = 0.08,
        maxBlockSize: CGFloat = 12
    ) -> some View {
        modifier(PixelateWaveEffect(
            progress: progress,
            layerWidth: layerWidth,
            bandSoftness: bandSoftness,
            maxBlockSize: maxBlockSize
        ))
    }
}
