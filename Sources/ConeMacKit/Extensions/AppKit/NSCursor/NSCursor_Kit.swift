//
//  File.swift
//  
//
//  Created by HanQi on 2024/8/19.
//

import AppKit

public extension NSCursor {
    
    class var nesw: NSCursor {
        struct Box {
            static var cursor : NSCursor?
        }
        if Box.cursor == nil {
              // 替换获取图片的方法
            let nesw = NSImage.resizeCursorImage(size: CGSize(width: 24, height: 24), margin: 4, direction: .obliqueUpward)
            Box.cursor = NSCursor(image: nesw, hotSpot: NSPoint(x: 10.0, y: 10.0))
        }
        return Box.cursor!
    }
    
    class var nwse: NSCursor {
        struct Box {
            static var cursor : NSCursor?
        }
        if Box.cursor == nil {
            // 替换获取图片的方法
            let nwse = NSImage.resizeCursorImage(size: CGSize(width: 24, height: 24), margin: 4, direction: .obliqueDescent)
            Box.cursor = NSCursor(image: nwse, hotSpot: NSPoint(x: 10.0, y: 10.0))
        }
        return Box.cursor!
    }
    
}


public extension NSImage {
    enum ResizeCursordirection {
        case obliqueUpward
        case obliqueDescent
    }
    static func resizeCursorImage(size: CGSize, margin: CGFloat, direction: ResizeCursordirection) -> NSImage {
        let image = NSImage(size: size, flipped: true) { rect in

            let contentRect = rect.insetBy(dx: margin, dy: margin)
            let w = contentRect.width
            let h = contentRect.height
            
            let lineWidth = w * 0.15
            let cornerSizeScale = 0.35
            let mainAnchorScale = 0.89
            
            let mainPath = NSBezierPath()
            mainPath.move(to: CGPoint(x: 0 * w + lineWidth / 2  + margin, y: (1 - mainAnchorScale) * h + lineWidth / 2 + margin))
            mainPath.line(to: CGPoint(x: mainAnchorScale * w - lineWidth / 2 + margin, y: 1 * h - lineWidth / 2 + margin))
            mainPath.line(to: CGPoint(x: 1 * w - lineWidth / 2 + margin, y: mainAnchorScale * h - lineWidth / 2 + margin))
            mainPath.line(to: CGPoint(x: (1 - mainAnchorScale) * w + lineWidth / 2 + margin, y: 0 * h + lineWidth / 2 + margin))
            mainPath.close()
              
            let cornerTopPath = NSBezierPath()
            cornerTopPath.move(to: CGPoint(x: 0 * w + lineWidth / 2 + margin, y: 0 * h + lineWidth / 2 + margin))
            cornerTopPath.line(to: CGPoint(x: 0 * w + lineWidth / 2 + margin, y: cornerSizeScale * h + lineWidth / 2 + margin))
            cornerTopPath.line(to: CGPoint(x: cornerSizeScale * w + lineWidth / 2 + margin, y: 0 * h + lineWidth / 2 + margin))
            cornerTopPath.close()
            mainPath.append(cornerTopPath)
            
            let cornerBottomPath = NSBezierPath()
            cornerBottomPath.move(to: CGPoint(x: 1 * w - lineWidth / 2 + margin, y: 1 * h - lineWidth / 2 + margin))
            cornerBottomPath.line(to: CGPoint(x: 1 * w - lineWidth / 2 + margin, y: (1 - cornerSizeScale) * h - lineWidth / 2 + margin))
            cornerBottomPath.line(to: CGPoint(x: (1 - cornerSizeScale) * w - lineWidth / 2 + margin, y: 1 * h - lineWidth / 2 + margin))
            cornerBottomPath.close()
            mainPath.append(cornerBottomPath)
            
            if direction == .obliqueUpward {
                var transform = AffineTransform()
                
                let pathBounds = mainPath.bounds
                let centerX = pathBounds.midX
                let centerY = pathBounds.midY
                
                let anchorPoint = NSPoint(x: centerX, y: centerY)
                transform.translate(x: +anchorPoint.x, y: +anchorPoint.y)
 
                let rotationAngle = 90.0
                transform.rotate(byDegrees: CGFloat(rotationAngle))
                transform.translate(x: -anchorPoint.x, y: -anchorPoint.y)
                mainPath.transform(using: transform)
            }
            
            mainPath.lineWidth = lineWidth
            NSColor.white.setStroke()
            mainPath.stroke()
             
            NSColor.black.setFill()
            mainPath.fill()
             
            return true
        }
        
        return image
    }
    
}
