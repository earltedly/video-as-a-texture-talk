import AppKit
import AVFoundation
import PlaygroundSupport

public extension AVPlayer {
    
    func toLiveView(frame: CGRect = CGRect(x: 0, y: 0, width: 1024/2, height: 768/2)) {
        // Player layer
        let layer = AVPlayerLayer(player: self)
        layer.bounds = frame
        layer.anchorPoint = .zero
        
        // View
        let view = NSView()
        view.frame = layer.frame
        view.wantsLayer = true
        view.layer?.addSublayer(layer)
        
        // Playground
        PlaygroundPage.current.liveView = view
        PlaygroundPage.current.needsIndefiniteExecution = true
    }
}
