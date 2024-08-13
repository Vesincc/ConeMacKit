//
//  CGPoint_Kit.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import Foundation

public extension CGPoint {
    
    /// 两点间距
    /// - Parameter point: point
    /// - Returns: res
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
    
}
