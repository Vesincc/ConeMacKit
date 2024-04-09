//
//  File.swift
//  
//
//  Created by HanQi on 2023/12/6.
//

import Foundation
import CoreGraphics

public extension CGRect {
    
    /// 通过点的集合(不定参)创建矩形
    /// - Parameter points: points
    init(points : CGPoint...) {
        if points.count < 2 {
            fatalError("必须传入至少两个点")
        }
        var minX = points.first!.x
        var minY = points.first!.y
        var maxX = points.first!.x
        var maxY = points.first!.y

        for point in points {
            if point.x > maxX {
                maxX = point.x
            }
            if point.x < minX {
                minX = point.x
            }
            if point.y > maxY {
                maxY = point.y
            }
            if point.y < minY {
                minY = point.y
            }
        }
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    
}

public extension CGRect {
    
    
    /// 给矩形追加点 形成新的矩形新的矩形取原来矩形和传入点最小最大值形成. 注：该函数修改自身.
    /// - Parameter point: point
    mutating func append(point : CGPoint) {
        let minX = point.x < self.minX ? point.x : self.minX
        let minY = point.y < self.minY ? point.y : self.minY
        let maxX = point.x > self.maxX ? point.x : self.maxX
        let maxY = point.y > self.maxY ? point.y : self.maxY
        self.origin.x = minX
        self.origin.y = minY
        self.size.width = maxX - minX
        self.size.height = maxY - minY
    }
     
    
    /// 在限定高度内翻转y
    /// - Parameter height: 高度
    /// - Returns: res
    func flip(in height: CGFloat) -> CGRect {
        CGRect(origin: CGPoint(x: minX, y: height - maxY), size: size)
    }
    
    
    /// 限制区域
    /// - Parameter rect: 限定区域
    /// - Returns: res
    func limit(in rect: CGRect) -> CGRect {
        var tRect = self
        tRect.origin.x = max(rect.minX, tRect.minX)
        tRect.origin.y = max(rect.minY, tRect.minY)
        if tRect.maxX > rect.maxX {
            tRect.size.width = rect.maxX - tRect.minX
        }
        if tRect.maxY > rect.maxY {
            tRect.size.height = rect.maxY - tRect.minY
        }
        return tRect
    }
      
    
    /// 圆角路径
    /// - Parameters:
    ///   - topLeft: topLeft
    ///   - topRight: topRight
    ///   - bottomLeft: bottomLeft
    ///   - bottomRight: bottomRight
    /// - Returns: res
    func cornerPath(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        // 设置绘制起点为（minx, midy）
        path.move(to: NSPoint(x: minX, y: midY))
        // 绘制view左下圆角
        path.addArc(tangent1End: CGPoint(x: minX, y: minY), tangent2End: CGPoint(x: midX, y: minY), radius: bottomLeft)
        // 绘制view右下圆角
        path.addArc(tangent1End: CGPoint(x: maxX, y: minY), tangent2End: CGPoint(x: maxX, y: midY), radius: bottomRight)
        
        // 绘制view右上圆角
        path.addArc(tangent1End: CGPoint(x: maxX, y: maxY), tangent2End: CGPoint(x: midX, y: maxY), radius: topRight)
        // 绘制view左上圆角
        path.addArc(tangent1End: CGPoint(x: minX, y: maxY), tangent2End: CGPoint(x: minX, y: midY), radius: topLeft)
        return path
    }
      
}
