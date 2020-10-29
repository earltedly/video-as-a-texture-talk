//: [Previous](@previous)

import AppKit
import AVFoundation

let player = AVPlayer(url: .bipbop)

let target = CMTime(seconds: 2.37, preferredTimescale: .init(1000))
let delta = {
    player.currentTime().seconds - target.seconds
}

player.addBoundaryTimeObserver(forTimes: [NSValue(time: target)], queue: nil) {
    player.pause()
    delta()
    player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
        print(delta())
    }
}
player.play()

player.toLiveView()

//: [Next](@next)
