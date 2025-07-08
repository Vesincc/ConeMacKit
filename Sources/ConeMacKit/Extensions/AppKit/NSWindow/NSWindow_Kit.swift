//
//  NSWindow_Kit.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import AppKit

public extension NSWindow {
    
    enum WindowAlignment {
        case top
        case left
        case right
        case bottom
        case center
    }
    
    /// window居中
    /// - Parameters:
    ///   - targetWindow: targetWindow
    ///   - offset: 偏移
    func center(aligment targetWindow: NSWindow?, offset: CGPoint = .zero) {
        alignment(.center, targetWindow: targetWindow, offset: offset)
        
    }
    
    /// 将窗口对齐于目标窗口或屏幕的指定方向
    /// - Parameters:
    ///   - alignment: 对齐方式（上、下、左、右）
    ///   - targetWindow: 目标窗口，nil 表示当前窗口所在屏幕
    ///   - offset: 偏移量
    func alignment(_ alignment: WindowAlignment, targetWindow: NSWindow? = nil, offset: CGPoint = .zero) {
        guard self != targetWindow else { return }
        
        let baseFrame: NSRect
        if let target = targetWindow {
            baseFrame = target.frame
        } else if let screen = self.screen ?? NSScreen.main {
            baseFrame = screen.frame
        } else {
            return
        }
        
        var newOrigin = frame.origin
        
        switch alignment {
        case .top:
            newOrigin.x = baseFrame.midX - frame.width / 2 + offset.x
            newOrigin.y = baseFrame.maxY - frame.height + offset.y
            
        case .bottom:
            newOrigin.x = baseFrame.midX - frame.width / 2 + offset.x
            newOrigin.y = baseFrame.minY + offset.y
            
        case .left:
            newOrigin.x = baseFrame.minX + offset.x
            newOrigin.y = baseFrame.midY - frame.height / 2 + offset.y
            
        case .right:
            newOrigin.x = baseFrame.maxX - frame.width + offset.x
            newOrigin.y = baseFrame.midY - frame.height / 2 + offset.y
            
        case .center:
            newOrigin.x = baseFrame.origin.x + (baseFrame.width - frame.width) / 2 + offset.x
            newOrigin.y = baseFrame.origin.y + (baseFrame.height - frame.height) / 2 + offset.y
        }
        
        setFrameOrigin(NSPoint(x: round(newOrigin.x), y: round(newOrigin.y)))
    }
    
}
