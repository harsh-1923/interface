//
//  Pixelate.metal
//  Interface
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

/// Pixelates the layer by dividing it into blocks and sampling the center of each block.
/// `blockSize`: width and height of each block in points (1 = no pixelation, larger = more blocky).
[[ stitchable ]]
half4 Pixelate(float2 position, SwiftUI::Layer layer, float blockSize) {
    if (blockSize <= 1.0) {
        return layer.sample(position);
    }
    float2 blockCoord = floor(position / blockSize);
    float2 center = (blockCoord + 0.5) * blockSize;
    return layer.sample(center);
}

/// Pixelates with a left-to-right sweep: left edge first, then the next “column” and so on.
/// `progress`: 0 = no pixelation, 1 = fully pixelated (animated 0→1 to pixelate, 1→0 to depixelate).
/// `layerWidth`: width of the layer in points (for normalizing position.x).
/// `bandSoftness`: width of the soft edge in normalized space (0–1).
/// `maxBlockSize`: block size in the pixelated region.
[[ stitchable ]]
half4 PixelateWave(
    float2 position, SwiftUI::Layer layer,
    float progress, float layerWidth, float bandSoftness, float maxBlockSize
) {
    float normalizedX = layerWidth > 0.0 ? (position.x / layerWidth) : 0.0;
    // influence: 0 to the left of the front (pixelated), 1 to the right (normal)
    float influence = smoothstep(progress - bandSoftness, progress + bandSoftness, normalizedX);
    float blockSize = mix(maxBlockSize, 1.0, influence);

    if (blockSize <= 1.0) {
        return layer.sample(position);
    }
    float2 blockCoord = floor(position / blockSize);
    float2 center = (blockCoord + 0.5) * blockSize;
    return layer.sample(center);
}
