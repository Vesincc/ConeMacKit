//
//  File.swift
//
//
//  Created by HanQi on 2023/11/6.
//

import Foundation
import AppKit
 
/// 支持图片/标题自定义布局的 NSButtonCell 子类。
/// 可自定义间距、内边距、图片/文字垂直偏移，并支持标题压缩适应宽度。
open class SpacingButtonCell: NSButtonCell {
     
    /// 图片在垂直方向上的偏移量（+向下，-向上）
    @IBInspectable public var imageYOffset: CGFloat = 0
    
    /// 标题在垂直方向上的偏移量（+向下，-向上）
    @IBInspectable public var titleYOffset: CGFloat = 0
 
    /// 图片与标题之间的间距
    @IBInspectable public var spacing: CGFloat = 0

    /// 内容区域左边距
    @IBInspectable public var leftEdgeInset: CGFloat {
        get {
            contentEdgeInset.left
        }
        set {
            contentEdgeInset.left = newValue
        }
    }

    /// 内容区域上边距
    @IBInspectable public var topEdgeInset: CGFloat {
        get {
            contentEdgeInset.top
        }
        set {
            contentEdgeInset.top = newValue
        }
    }

    /// 内容区域右边距
    @IBInspectable public var rightEdgeInset: CGFloat {
        get {
            contentEdgeInset.right
        }
        set {
            contentEdgeInset.right = newValue
        }
    }

    /// 内容区域下边距
    @IBInspectable public var bottomEdgeInset: CGFloat {
        get {
            contentEdgeInset.bottom
        }
        set {
            contentEdgeInset.bottom = newValue
        }
    }
     
    /// title是否填充剩余区域
    /// - 默认为 false，表示标题将使用其原始宽度，不会填充。
    /// - 设置为 true 时 title填满剩余位置 可以通过调整 aligment 调整文本对齐
    @IBInspectable public var titleShouldFillCellSpace: Bool = false
    
    /// 内容区域内边距（对应上/左/下/右）
    public var contentEdgeInset: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    private var textFieldCell = NSTextFieldCell()
    
    public override var cellSize: NSSize {
        CGSize(width: contentFullLayout().contentSize.width + contentEdgeInset.left + contentEdgeInset.right,
               height: contentFullLayout().contentSize.height + contentEdgeInset.top + contentEdgeInset.bottom).ceilSize
    }
    
    public override func cellSize(forBounds rect: NSRect) -> NSSize {
        CGSize(width: contentFullLayout().contentSize.width + contentEdgeInset.left + contentEdgeInset.right,
               height: contentFullLayout().contentSize.height + contentEdgeInset.top + contentEdgeInset.bottom).ceilSize
    }
    
    
    
    public override func imageRect(forBounds rect: NSRect) -> NSRect {
        fittingLayout(in: rect).image.pixelAlignment.offsetBy(dx: 0, dy: imageYOffset)
    }

    public override func titleRect(forBounds rect: NSRect) -> NSRect {
        fittingLayout(in: rect).title.pixelAlignment.offsetBy(dx: 0, dy: titleYOffset)
    }
    
    
}


// MARK: - 位置辅助
fileprivate extension SpacingButtonCell {
    
    private enum ImagePosition {
        case noImage
        case imageOnly
        case left
        case right
        /// 上
        case above
        /// 下
        case below
        case overlaps
    }
    
    private var imagePositionWithUserInterfaceLayoutDirection: ImagePosition {
        if image == nil || imageFullSize.isZero {
            return .noImage
        }
        switch imagePosition {
        case .noImage:
            return .noImage
        case .imageOnly:
            return .imageOnly
        case .imageLeft:
            return .left
        case .imageRight:
            return .right
        case .imageBelow:
            return .below
        case .imageAbove:
            return .above
        case .imageOverlaps:
            return .overlaps
        case .imageLeading:
            return userInterfaceLayoutDirection == .leftToRight ? .left : .right
        case .imageTrailing:
            return userInterfaceLayoutDirection == .leftToRight ? .right : .left
        @unknown default:
            return .overlaps
        }
    }
}


// MARK: - 计算全尺寸
fileprivate extension SpacingButtonCell {
    
    /// 全尺寸内容布局
    func contentFullLayout() -> (contentSize: CGSize, imageRect: CGRect, titleRect: CGRect) {
        let imageSize = imageFullSize
        let titleSize = titleFullSize
        
        switch imagePositionWithUserInterfaceLayoutDirection {
        case .noImage:
            return (
                titleSize,
                .zero,
                CGRect(origin: .zero, size: titleSize)
            )
            
        case .imageOnly:
            return (
                imageSize,
                CGRect(origin: .zero, size: imageSize),
                .zero
            )
            
        case .left:
            let totalWidth = imageSize.width + spacing + titleSize.width
            let height = max(imageSize.height, titleSize.height)
            
            let imageOrigin = CGPoint(
                x: 0,
                y: (height - imageSize.height) / 2
            )
            let titleOrigin = CGPoint(
                x: imageSize.width + spacing,
                y: (height - titleSize.height) / 2
            )
            
            return (
                CGSize(width: totalWidth, height: height),
                CGRect(origin: imageOrigin, size: imageSize),
                CGRect(origin: titleOrigin, size: titleSize)
            )
            
        case .right:
            let totalWidth = titleSize.width + spacing + imageSize.width
            let height = max(imageSize.height, titleSize.height)
            
            let titleOrigin = CGPoint(
                x: 0,
                y: (height - titleSize.height) / 2
            )
            let imageOrigin = CGPoint(
                x: titleSize.width + spacing,
                y: (height - imageSize.height) / 2
            )
            
            return (
                CGSize(width: totalWidth, height: height),
                CGRect(origin: imageOrigin, size: imageSize),
                CGRect(origin: titleOrigin, size: titleSize)
            )
            
        case .above:
            let totalHeight = imageSize.height + spacing + titleSize.height
            let width = max(imageSize.width, titleSize.width)
            
            let imageOrigin = CGPoint(
                x: (width - imageSize.width) / 2,
                y: 0
            )
            let titleOrigin = CGPoint(
                x: (width - titleSize.width) / 2,
                y: imageSize.height + spacing
            )
            
            return (
                CGSize(width: width, height: totalHeight),
                CGRect(origin: imageOrigin, size: imageSize),
                CGRect(origin: titleOrigin, size: titleSize)
            )
            
        case .below:
            let totalHeight = titleSize.height + spacing + imageSize.height
            let width = max(imageSize.width, titleSize.width)
            
            let titleOrigin = CGPoint(
                x: (width - titleSize.width) / 2,
                y: 0
            )
            let imageOrigin = CGPoint(
                x: (width - imageSize.width) / 2,
                y: titleSize.height + spacing
            )
            
            return (
                CGSize(width: width, height: totalHeight),
                CGRect(origin: imageOrigin, size: imageSize),
                CGRect(origin: titleOrigin, size: titleSize)
            )
            
        case .overlaps:
            let width = max(imageSize.width, titleSize.width)
            let height = max(imageSize.height, titleSize.height)
            
            let imageOrigin = CGPoint(
                x: (width - imageSize.width) / 2,
                y: (height - imageSize.height) / 2
            )
            let titleOrigin = CGPoint(
                x: (width - titleSize.width) / 2,
                y: (height - titleSize.height) / 2
            )
            
            return (
                CGSize(width: width, height: height),
                CGRect(origin: imageOrigin, size: imageSize),
                CGRect(origin: titleOrigin, size: titleSize)
            )
        }
    }
    
    /// 标题全尺寸（单行）
    var titleFullSize: CGSize {
        let attributed: NSAttributedString = {
            if let font = font, !title.isEmpty {
                return NSAttributedString(string: title, attributes: [.font: font])
            } else {
                return attributedTitle
            }
        }()
        textFieldCell.attributedStringValue = attributed
        return textFieldCell.cellSize
    }
    
    /// 图片全尺寸
    var imageFullSize: CGSize {
        guard let size = image?.size else { return .zero }
        return CGSize(width: size.width, height: size.height)
    }
    
}

// MARK: - 重新布局
fileprivate extension SpacingButtonCell {
    
    
    func fittingLayout(in rect: CGRect) -> (image: CGRect, title: CGRect) {
        let fullLayout = contentFullLayout()
        let imageSize = imageFullSize
        let titleSize = titleFullSize
        
        let targetRect = CGRect(x: contentEdgeInset.left,
                                y: contentEdgeInset.top,
                                width: rect.width - contentEdgeInset.left - contentEdgeInset.right,
                                height: rect.height - contentEdgeInset.top - contentEdgeInset.bottom)
         
        let imagePosition = imagePositionWithUserInterfaceLayoutDirection
        
        var fittingSize = targetRect.size
        if !titleShouldFillCellSpace {
            fittingSize = CGSize(width: min(targetRect.width, fullLayout.contentSize.width), height: min(targetRect.height, fullLayout.contentSize.height))
        }
        
        var fittingImageSize: CGSize = .zero
        var fittingTitleSize: CGSize = .zero
        
        var fittingImageOrigin: CGPoint = .zero
        var fittingTitleOrigin: CGPoint = .zero
         
        switch imagePosition {
        case .noImage:
            let availableWidth = fittingSize.width
             
            fittingImageSize = .zero
            fittingTitleSize = CGSize(width: titleShouldFillCellSpace ? availableWidth : min(availableWidth, titleSize.width),
                                      height: min(titleSize.height, fittingSize.height))
            
            fittingImageOrigin = .zero
            fittingTitleOrigin = CGPoint(x: (fittingSize.width - fittingTitleSize.width) / 2,
                                         y: (fittingSize.height - fittingTitleSize.height) / 2)
            
        case .imageOnly:
            fittingImageSize = CGSize(width: min(imageSize.width ,fittingSize.width),
                                      height: min(imageSize.height, fittingSize.height))
            fittingTitleSize = .zero
            
            fittingImageOrigin = CGPoint(x: (fittingSize.width - fittingImageSize.width) / 2,
                                         y: (fittingSize.height - fittingImageSize.height) / 2)
            fittingTitleOrigin = .zero
            
        case .left, .right:
            fittingImageSize = CGSize(width: min(imageSize.width ,fittingSize.width),
                                      height: min(imageSize.height, fittingSize.height))
            let availableWidth = max(fittingSize.width - fittingImageSize.width - spacing, 0)
            fittingTitleSize = CGSize(width: titleShouldFillCellSpace ? availableWidth : min(availableWidth, titleSize.width),
                                      height: min(titleSize.height, fittingSize.height))
            
            if imagePosition == .left {
                fittingImageOrigin = CGPoint(x: 0, y: (fittingSize.height - fittingImageSize.height) / 2)
                fittingTitleOrigin = CGPoint(x: fittingImageSize.width + spacing, y: (fittingSize.height - fittingTitleSize.height) / 2)
            } else {
                fittingTitleOrigin = CGPoint(x: 0, y: (fittingSize.height - fittingTitleSize.height) / 2)
                fittingImageOrigin = CGPoint(x: fittingTitleSize.width + spacing, y: (fittingSize.height - fittingImageSize.height) / 2)
            }
             
        case .above, .below:
            fittingImageSize = CGSize(width: min(imageSize.width ,fittingSize.width),
                                      height: min(imageSize.height, fittingSize.height))
            let availableHeight = max(fittingSize.height - fittingImageSize.height - spacing, 0)
            fittingTitleSize = CGSize(width: min(titleSize.width, fittingSize.width),
                                      height: titleShouldFillCellSpace ? availableHeight : min(availableHeight, titleSize.height))
            
            if imagePosition == .above {
                fittingImageOrigin = CGPoint(x: (fittingSize.width - fittingImageSize.width) / 2, y: 0)
                fittingTitleOrigin = CGPoint(x: (fittingSize.width - fittingTitleSize.width) / 2,  y: fittingImageSize.height + spacing)
            } else {
                fittingTitleOrigin = CGPoint(x: (fittingSize.width - fittingTitleSize.width) / 2, y: 0)
                fittingImageOrigin = CGPoint(x: (fittingSize.width - fittingImageSize.width) / 2, y: fittingTitleSize.height + spacing)
            }
        case .overlaps:
            fittingImageSize = CGSize(width: min(imageSize.width, fittingSize.width),
                                      height: min(imageSize.height, fittingSize.height))
            fittingTitleSize = CGSize(width: min(titleSize.width, fittingSize.width),
                                      height: min(titleSize.height, fittingSize.height))
            
            fittingImageOrigin = CGPoint(x: (fittingSize.width - fittingImageSize.width) / 2,
                                         y: (fittingSize.height - fittingImageSize.height) / 2)
            fittingTitleOrigin = CGPoint(x: (fittingSize.width - fittingTitleSize.width) / 2,
                                         y: (fittingSize.height - fittingTitleSize.height) / 2)
        }
        
        let imageRect = CGRect(origin: CGPoint(x: (rect.width - fittingSize.width) / 2 + fittingImageOrigin.x, y: (rect.height - fittingSize.height) / 2 + fittingImageOrigin.y),
                               size: fittingImageSize)
        let titleRect = CGRect(origin: CGPoint(x: (rect.width - fittingSize.width) / 2 + fittingTitleOrigin.x, y: (rect.height - fittingSize.height) / 2 + fittingTitleOrigin.y),
                               size: fittingTitleSize)
        
        return (imageRect, titleRect)
    }
     
}

fileprivate extension CGSize {
    var isZero: Bool {
        width <= 0 || height <= 0
    }
    var ceilSize: CGSize {
        CGSize(width: ceil(width), height: ceil(height))
    }
}

fileprivate extension CGRect {
    var pixelAlignment: CGRect {
        let oldX = origin.x
        let oldY = origin.y
        
        let newX = floor(oldX)
        let newY = floor(oldY)
        
        let dx = oldX - newX
        let dy = oldY - newY
        
        let newWidth = ceil(size.width + dx)
        let newHeight = ceil(size.height + dy)
        
        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
}
