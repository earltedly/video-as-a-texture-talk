//
//  TexturedQuad.swift
//  MetalVideoDemo
//
//  Created by Ted Bradley on 29/10/2020.
//

import Foundation
import MetalKit

/// Responsible for drawing a texture which covers the entire view by default
class TexturedQuad {
    private let device: MTLDevice
    private let pipelineDescriptor = MTLRenderPipelineDescriptor()
    private let pipelineState: MTLRenderPipelineState

    private let vertexBuffer: MTLBuffer
    private let mesh: MTKMesh

    init(device: MTLDevice, vertexFunction: String = "vertex_main", fragmentFunction: String = "fragment_main", library: MTLLibrary, colorPixelFormat: MTLPixelFormat) throws {
        self.device = device
        
        let allocator = MTKMeshBufferAllocator(device: device)
        let quad = MDLMesh(planeWithExtent: [2, 2, 1], segments: [1, 1], geometryType: .triangles, allocator: allocator)
        mesh = try MTKMesh(mesh: quad, device: device)
        vertexBuffer = mesh.vertexBuffers[0].buffer

        pipelineDescriptor.vertexFunction = library.makeFunction(name: vertexFunction)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: fragmentFunction)
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        
        pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    func draw(with renderEncoder: MTLRenderCommandEncoder, videoTexture: MTLTexture) {
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(videoTexture, index: 0)

        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
