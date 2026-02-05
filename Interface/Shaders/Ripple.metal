//
//  Ripple.metal
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 Ripple(
    float2 position, SwiftUI::Layer layer, float2 origin,
    float time, float amplitude, float frequency, float decay, float speed,
    float redIntensity
) {
    float distance = length(position - origin);
    float delay = distance / speed;
    time = max(0.0, time - delay);
    
    float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);
    float2 n = normalize(position - origin);
    float2 newPosition = position + rippleAmount * n;
    
    half4 color = layer.sample(newPosition);
    float influence = abs(rippleAmount / amplitude);
    color.rgb += 0.3 * influence * color.a;
    // Red tint where the wave affects the pixel (scaled by redIntensity)
    color.r += redIntensity * 0.95 * influence;
    color.gb -= redIntensity * 0.92 * influence;
    return color;
}
