import AppKit
import AVFoundation

let asset = AVAsset(url: .bipbop)
let filter = CIFilter(name: "CIGaussianBlur")!
let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
    // Clamp to avoid blurring transparent pixels at the image edges
    let source = request.sourceImage.clampedToExtent()
    filter.setValue(source, forKey: kCIInputImageKey)
    
    // Vary filter parameters based on video timing
    let seconds = CMTimeGetSeconds(request.compositionTime)
    filter.setValue(seconds * 3, forKey: kCIInputRadiusKey)
    
    // Crop the blurred output to the bounds of the original image
    let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
    
    // Provide the filter output to the composition
    request.finish(with: output, context: nil)
})

let item = AVPlayerItem(asset: asset)
item.videoComposition = composition
let player = AVPlayer(playerItem: item)
player.volume = 0
player.play()

player.toLiveView()
