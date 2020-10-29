//: [Previous](@previous)

import AppKit
import AVFoundation

let player = AVPlayer(url: .bipbop)
player.isMuted = true

let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)

// We can't add the `videoOutput` until the item is ready to play
let playerObserver = player.observe(\AVPlayer.currentItem?.status, options: [.initial]) { (player, value) in
    guard player.currentItem?.status == .readyToPlay else { return }
    player.currentItem?.add(videoOutput)
    player.play()
}

// We can now poll for frames
let interval = CMTime(seconds: 1.0/60.0, preferredTimescale: .init(1000))
let periodic = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { (time) in
    guard player.status == .readyToPlay else { return }

    let itemTime = player.currentTime()
    guard videoOutput.hasNewPixelBuffer(forItemTime: itemTime) else { return }

    if let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
        guard let surface = CVPixelBufferGetIOSurface(pixelBuffer)?.retain() else { return }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        doSomething(surface, width: width, height: height)
    }
}

func doSomething(_ surface: Unmanaged<IOSurfaceRef>, width: Int, height: Int) {
    // Do something with the surface
    surface.release()
}

player.toLiveView()

//: [Next](@next)
