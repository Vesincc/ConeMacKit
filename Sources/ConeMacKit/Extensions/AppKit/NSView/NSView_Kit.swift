//
//  File.swift
//  
//
//  Created by HanQi on 2024/8/21.
//

import AppKit


public extension NSView {
    
    var anchorPoint: CGPoint? {
        get {
            layer?.anchorPoint
        }
        set {
            let newPoint = newValue ?? .zero
            let oldPoint: CGPoint = layer?.anchorPoint ?? .zero
            let offsetPoint = CGPoint(x: newPoint.x - oldPoint.x, y: newPoint.y - oldPoint.y)
            let layerSize = layer?.bounds ?? .zero
            let offset = CGPoint(x: offsetPoint.x * layerSize.width, y: offsetPoint.y * layerSize.height)
            layer?.anchorPoint = newPoint
            let oldPosition = layer?.position ?? .zero
            layer?.position = CGPoint(x: oldPosition.x + offset.x, y: oldPosition.y + offset.y)
        }
    }
    
}
