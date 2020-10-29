//
//  Player.swift
//  MetalVideoDemo
//
//  Created by Ted Bradley on 29/10/2020.
//

import MetalKit
import AVFoundation

/// Wraps an AVPlayer and provides access to the current frame as a `MTLTexture`
class Player {
    var texture: MTLTexture?
    
    private let device: MTLDevice
    
    /// The values in `pixelBufferAttributes` instruct the hardware decoder how to process the video
    private let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [
        String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA),
        String(kCVPixelBufferMetalCompatibilityKey): NSNumber(booleanLiteral: true)
    ])
    
    private let player: AVPlayer
    private var playerObserver: NSKeyValueObservation?
    
    private var cache = [Any]()
    
    init(_ device: MTLDevice, url: URL) {
        self.device = device
        
        player = AVPlayer(url: url)
        
        videoOutput.suppressesPlayerRendering = true
        
        // We can't add the `videoOutput` until the `AVPlayerItem` is `readyToPlay`
        playerObserver = player.observe(\AVPlayer.currentItem?.status,
                                        options: [.initial]) { [weak self = self] (player, _) in
            guard player.currentItem?.status == .readyToPlay, let `self` = self else { return }
            player.currentItem?.add(self.videoOutput)
            player.play()
        }
    }
    
    func updateVideoTexture() throws {
        guard player.status == .readyToPlay else { return }
        
        let itemTime = player.currentTime()
        guard videoOutput.hasNewPixelBuffer(forItemTime: itemTime) else { return }

        if let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
            self.texture = try convertToMTLTexture(pixelBuffer)
        }
    }
    
    private func convertToMTLTexture(_ pixelBuffer: CVPixelBuffer) throws -> MTLTexture {
        // We need to keep a reference to the pixelbuffer for as long as we need access to the
        // underlying memory. We keep these in a ringbuffer.
        cache(pixelBuffer, last: 3)
        
        guard let surface = CVPixelBufferGetIOSurface(pixelBuffer) else {
            throw "Could not get an IOSurface"
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                  width: width,
                                                                  height: height,
                                                                  mipmapped: false)
        descriptor.usage = .shaderRead
        
        guard let texture = device.makeTexture(descriptor: descriptor,
                                               iosurface: surface.takeUnretainedValue(),
                                               plane: 0) else {
            throw "Could not create texture"
        }
        
        return texture
    }
    
    private func cache(_ pixelBuffer: CVPixelBuffer, last: Int) {
        cache.append(pixelBuffer)
        if cache.count > last {
            cache.removeFirst()
        }
    }
}
