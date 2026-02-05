//
//  Wave.metal
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
float2 wave(float2 pos, float t) {
    pos.y += sin(4 * t + pos.y) * 5;
    return pos;
    
    
//    float angle = atan2(pos.x, pos.y) + t;
//    return half4(
//                 sin(angle),
//                 sin(angle + 2),
//                 sin(angle + 4),
//                 color.a
//                 );
}
