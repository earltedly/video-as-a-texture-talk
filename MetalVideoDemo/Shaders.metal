//
//  Shaders.metal
//  MetalVideoDemo
//
//  Created by Ted Bradley on 29/10/2020.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float2 uv [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[ stage_in ]]) {
    VertexOut out;
    out.position = vertexIn.position;
    out.uv = vertexIn.uv;
    
    // The video texture is flipped so we invert the y
    out.uv.y = out.uv.y * -1 + 1;

    return out;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]],
                              texture2d<float> videoTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler;
    return videoTexture.sample(textureSampler, in.uv);
}

