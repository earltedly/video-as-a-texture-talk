//
//  Renderer.swift
//  MetalVideoDemo
//
//  Created by Ted Bradley on 29/10/2020.
//

import MetalKit

/// A Metal renderer which displays the frames for a `Player`
class Renderer: NSObject {    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    
    private let player: Player
    private let quad: TexturedQuad
    
    init(_ metalView: MTKView) throws {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary(),
              let commandQueue = device.makeCommandQueue() else {
            throw "Failed to initialize Metal"
        }
        
        self.device = device
        self.commandQueue = commandQueue
        
        metalView.device = device
        
        let url = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!
        player = Player(device, url: url)
        quad = try TexturedQuad(device: device, library: library, colorPixelFormat: metalView.colorPixelFormat)
        
        super.init()
        
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        do {
            try player.updateVideoTexture()
        } catch {
            print(error)
        }
        
        guard
            let texture = player.texture,
            let frameDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: frameDescriptor) else {
            return
        }
        
        quad.draw(with: renderEncoder, videoTexture: texture)
        renderEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
}
