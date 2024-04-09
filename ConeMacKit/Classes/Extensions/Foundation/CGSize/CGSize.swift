//
//  CGSize.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/9.
//

import Foundation

public extension CGSize {
    
    /// 比例填充
    /// - Parameter rect: rect
    /// - Returns: res
    func aspectFit(in rect: CGRect) -> CGRect {
        let ratio = width / height
        var newSize = NSSize.zero
        let inViewRatio = rect.width / rect.height
        if inViewRatio > ratio {
            newSize = NSSize(width: ratio * rect.height, height: rect.height)
        }else {
            newSize = NSSize(width: rect.width, height: rect.width / ratio)
        }
        return center(in: CGRect(origin: .zero, size: newSize))
    }
    
    /// 居中
    /// - Parameter rect: rect
    /// - Returns: res
    func center(in rect: CGRect) -> CGRect {
        NSRect(x: rect.midX - width * 0.5, y: rect.midY - height * 0.5, width: width, height: height)
    }
    
}
