//
//  NSWindow_Kit.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import AppKit

public extension NSWindow {
    
    
    /// window居中
    /// - Parameters:
    ///   - targetWindow: targetWindow
    ///   - offset: 偏移
    func center(aligment targetWindow: NSWindow?, offset: CGPoint? = nil) {
        guard self != targetWindow else {
            return
        }
        var targetWindow = targetWindow
        if targetWindow == self {
            targetWindow = nil
        }
        let origin = targetWindow?.frame.origin ?? .zero
        let aligmentSize: CGSize = targetWindow?.frame.size ?? targetWindow?.screen?.frame.size ?? NSScreen.main?.frame.size ?? .zero
        let currentSize = frame.size
        setFrame(CGRect(
            x: origin.x - ceil((currentSize.width - aligmentSize.width) / 2.0) + (offset?.x ?? 0),
            y: origin.y - ceil((currentSize.height - aligmentSize.height) / 2.0) + (offset?.y ?? 0),
            width: currentSize.width,
            height: currentSize.height), display: true)
        
    }
    
}
