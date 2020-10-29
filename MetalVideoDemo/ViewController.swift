//
//  ViewController.swift
//  MetalVideoDemo
//
//  Created by Ted Bradley on 29/10/2020.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    var renderer: Renderer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError()
        }
        do {
            renderer = try Renderer(metalView)
        } catch {
            print(error)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

