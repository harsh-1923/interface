//
//  Fold.metal
//  Interface
//
//  Layer effect: progressive tint + glow + disperse distortion from center.
//  Top half: red tint/glow; bottom half: blue. Disperse increases with distance.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

/// bounds: float4 from .boundingRect → (origin.x, origin.y, size.width, size.height)
[[ stitchable ]]
half4 Fold(
    float2 position,
    SwiftUI::Layer layer,
    float4 bounds,
    float foldAmount
) {
    float layerWidth = bounds.z;
    float layerHeight = bounds.w;
    float2 center = float2(bounds.x + layerWidth * 0.5, bounds.y + layerHeight * 0.5);

    if (layerHeight <= 0.0 || foldAmount <= 0.0) {
        return layer.sample(position);
    }

    float halfHeight = layerHeight * 0.5;
    float maxRadius = length(float2(layerWidth, layerHeight)) * 0.5;

    // Radial distance from center, normalized 0–1 (0 at center, 1 at edge)
    float2 toPos = position - center;
    float radialDist = length(toPos) / max(maxRadius, 0.001);
    radialDist = clamp(radialDist, 0.0, 1.0);

    // Disperse: sample from inward so image appears to stretch outward from center
    float disperseStrength = 0.35;
    float2 dispOffset = normalize(toPos) * disperseStrength * radialDist * foldAmount * maxRadius;
    float2 samplePos = position - dispOffset;

    half4 color = layer.sample(samplePos);

    // Vertical distance for tint/glow (top vs bottom half)
    float centerY = center.y;
    float distFromCenterY = abs(position.y - centerY) / halfHeight;
    distFromCenterY = clamp(distFromCenterY, 0.0, 1.0);

    half intensity = half(distFromCenterY * foldAmount);

    half3 redTint = half3(1.0, 0.0, 0.0);
    half3 blueTint = half3(0.0, 0.0, 1.0);

    bool isTop = position.y < centerY;
    half3 tintColor = isTop ? redTint : blueTint;

    color.rgb = mix(color.rgb, tintColor, intensity);

    half glowStrength = 0.35;
    color.rgb += tintColor * intensity * half(glowStrength);
    color.rgb = min(color.rgb, half3(1.0, 1.0, 1.0));

    return color;
}
