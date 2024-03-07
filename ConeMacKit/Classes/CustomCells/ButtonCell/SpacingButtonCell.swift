//
//  File.swift
//
//
//  Created by HanQi on 2023/11/6.
//

import Foundation
import Cocoa


public class SpacingButtonCell: NSButtonCell {


    @IBInspectable public var spacing: CGFloat = 0
     

    @IBInspectable public var leftEdgeInset: CGFloat {
        get {
            contentEdgeInset.left
        }
        set {
            contentEdgeInset.left = newValue
        }
    }

    @IBInspectable public var topEdgeInset: CGFloat {
        get {
            contentEdgeInset.top
        }
        set {
            contentEdgeInset.top = newValue
        }
    }

    @IBInspectable public var rightEdgeInset: CGFloat {
        get {
            contentEdgeInset.right
        }
        set {
            contentEdgeInset.right = newValue
        }
    }

    @IBInspectable public var bottomEdgeInset: CGFloat {
        get {
            contentEdgeInset.bottom
        }
        set {
            contentEdgeInset.bottom = newValue
        }
    }

    public var contentEdgeInset: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
 
    public override var cellSize: NSSize {
        CGSize(width: contentFullSize.width + contentEdgeInset.left + contentEdgeInset.right, height: contentFullSize.height + contentEdgeInset.top + contentEdgeInset.bottom)
    }
    
    public override func cellSize(forBounds rect: NSRect) -> NSSize {
        CGSize(width: contentFullSize.width + contentEdgeInset.left + contentEdgeInset.right, height: contentFullSize.height + contentEdgeInset.top + contentEdgeInset.bottom)
    }
     

    public override func imageRect(forBounds rect: NSRect) -> NSRect {
        let targetSize = CGSize(width: rect.size.width - leftEdgeInset - rightEdgeInset, height: rect.size.height - topEdgeInset - bottomEdgeInset)
        let contentSize = resizeContentSize(at: rect)
        let imageSize = resizeImageAndTitleSize(at: rect).imageSize
        let offset = resizeContentOffset(at: rect)

        let xSpacing = max(floor(targetSize.width - contentSize.width) / 2.0, 0)
        let ySpacing = max(floor(targetSize.height - contentSize.height) / 2.0, 0)
        switch alignment {
        case .left:
            return CGRect(
                x: CGFloat(floor(contentEdgeInset.left + offset.imageOffset.x)),
                y: CGFloat(floor(contentEdgeInset.top + ySpacing + offset.imageOffset.y)),
                width: imageSize.width,
                height: imageSize.height
            )
        case .right:
            return CGRect(
                x: CGFloat(floor(contentEdgeInset.left + 2 * xSpacing + offset.imageOffset.x)),
                y: CGFloat(floor(contentEdgeInset.top + offset.imageOffset.y)),
                width: imageSize.width,
                height: imageSize.height
            )
        default:
            return CGRect(
                x: CGFloat(floor(contentEdgeInset.left + xSpacing + offset.imageOffset.x)),
                y: CGFloat(floor(contentEdgeInset.top + ySpacing + offset.imageOffset.y)),
                width: imageSize.width,
                height: imageSize.height
            )
        }
    }

    public override func titleRect(forBounds rect: NSRect) -> NSRect {
        let targetSize = CGSize(width: rect.size.width - leftEdgeInset - rightEdgeInset, height: rect.size.height - topEdgeInset - bottomEdgeInset)
        let contentSize = resizeContentSize(at: rect)
        let titleSize = resizeImageAndTitleSize(at: rect).titleSize
        let offset = resizeContentOffset(at: rect)
        
        let xSpacing = max(floor(targetSize.width - contentSize.width) / 2.0, 0)
        let ySpacing = max(floor(targetSize.height - contentSize.height) / 2.0, 0)
        switch alignment {
        case .left:
            return CGRect(
                x: CGFloat(floor(contentEdgeInset.left + offset.titleOffset.x)),
                y: CGFloat(floor(contentEdgeInset.top + ySpacing + offset.titleOffset.y)),
                width: titleSize.width,
                height: titleSize.height
            )
        case .right:
            return CGRect(
                x: CGFloat(floor(contentEdgeInset.left + 2 * xSpacing + offset.titleOffset.x)),
                y: CGFloat(floor(contentEdgeInset.top + offset.titleOffset.y)),
                width: titleSize.width,
                height: titleSize.height
            )
        default:
            return CGRect(
                x: CGFloat(floor(contentEdgeInset.left + xSpacing + offset.titleOffset.x)),
                y: CGFloat(floor(contentEdgeInset.top + ySpacing + offset.titleOffset.y)),
                width: titleSize.width + 1,
                height: titleSize.height
            )
        }
        
        
    }
 

}


/// 全尺寸
fileprivate extension SpacingButtonCell {
     
    /// 全尺寸总大小
    var contentFullSize: CGSize {
        if titleFullSize.isZero, imageFullSize.isZero {
            return .zero
        }
        if titleFullSize.isZero {
            return imageFullSize
        }
        if imageFullSize.isZero {
            return titleFullSize
        }
        switch imagePosition {
        case .noImage:
            return titleFullSize
        case .imageOnly:
            return imageFullSize
        case .imageLeft, .imageRight, .imageLeading, .imageTrailing:
            return CGSize(width: titleFullSize.width + imageFullSize.width + spacing, height: max(imageFullSize.height, titleFullSize.height))
        case .imageBelow, .imageAbove:
            return CGSize(width: max(imageFullSize.width, titleFullSize.width), height: imageFullSize.height + titleFullSize.height + spacing)
        case .imageOverlaps:
            return CGSize(width: max(titleFullSize.width, imageFullSize.width), height: max(titleFullSize.height, imageFullSize.height))
        @unknown default:
            return CGSize(width: max(titleFullSize.width, imageFullSize.width), height: max(titleFullSize.height, imageFullSize.height))
        }
    }
    
    /// 全尺寸title大小
    var titleFullSize: CGSize {
        var stringSize: CGSize = .zero
        if let font = font, !title.isEmpty {
            stringSize = NSAttributedString(string: title, attributes: [
                NSAttributedString.Key.font : font
            ]).boundingRect(with: CGSize(width: 4000, height: 4000)).size
        } else {
            stringSize = attributedTitle.boundingRect(with: CGSize(width: 4000, height: 4000)).size
        }
        let cellSize = CGSize(width: stringSize.width + contentEdgeInset.left + contentEdgeInset.right, height: stringSize.height + contentEdgeInset.top + contentEdgeInset.bottom)
        let width: CGFloat = cellSize.width
        let height = cellSize.height
        var txtSize: CGSize = .zero
        if let font = font, !title.isEmpty {
            txtSize = NSAttributedString(string: title, attributes: [
                NSAttributedString.Key.font : font
            ]).boundingRect(with: CGSize(width: width - contentEdgeInset.left - contentEdgeInset.right, height: height - contentEdgeInset.top - contentEdgeInset.bottom)).size
        } else {
            txtSize = attributedTitle.boundingRect(with: CGSize(width: width - contentEdgeInset.left - contentEdgeInset.right, height: height - contentEdgeInset.top - contentEdgeInset.bottom)).size
        }
        return CGSize(width: ceil(txtSize.width), height: ceil(txtSize.height))
    }

    /// 全尺寸图片大小
    var imageFullSize: CGSize {
        guard let imageSize = image?.size else {
            return .zero
        }
        return CGSize(width: ceil(imageSize.width), height: ceil(imageSize.height))
    }
    
}

/// 调整尺寸
fileprivate extension SpacingButtonCell {
    
    
    /// 调整后内容尺寸
    /// - Parameter rect: rect
    /// - Returns: res
    func resizeContentSize(at rect: CGRect) -> CGSize {
        var size = resizeImageAndTitleSize(at: rect)
        size = (size.imageSize.alignment, size.titleSize.alignment)
        switch imagePosition {
        case .noImage:
            return size.titleSize
        case .imageOnly:
            return size.imageSize
        case .imageLeft, .imageRight, .imageLeading, .imageTrailing:
            return CGSize(width: size.titleSize.width + size.imageSize.width + spacing, height: max(size.titleSize.height, size.imageSize.height))
        case .imageBelow, .imageAbove:
            return CGSize(width: max(size.titleSize.width, size.imageSize.width), height: size.imageSize.height + size.titleSize.height + spacing)
        case .imageOverlaps:
            return CGSize(width: max(size.imageSize.width, size.titleSize.width), height: max(size.imageSize.height, size.titleSize.height))
        @unknown default:
            return CGSize(width: max(size.imageSize.width, size.titleSize.width), height: max(size.imageSize.height, size.titleSize.height))
        }
    }
    
    
    /// 调整尺寸后image和title尺寸
    /// - Parameter rect: rect
    /// - Returns: res
    func resizeImageAndTitleSize(at rect: CGRect) -> (imageSize: CGSize, titleSize: CGSize) {
        let targetSize = CGSize(width: rect.size.width - contentEdgeInset.left - contentEdgeInset.right, height: rect.size.height - contentEdgeInset.top - contentEdgeInset.bottom)
        guard !targetSize.isZero else {
            return (.zero, .zero)
        }
        let fullSize = contentFullSize
        let imageFullSize = self.imageFullSize
        let titleFullSize = self.titleFullSize
        if targetSize >= fullSize {
            return (imageFullSize, titleFullSize)
        }
        if titleFullSize.isZero, imageFullSize.isZero {
            return (.zero, .zero)
        }
        if titleFullSize.isZero {
            return (CGSize(width: min(targetSize.width, imageFullSize.width), height: min(targetSize.height, imageFullSize.height)), .zero)
        }
        if imageFullSize.isZero {
            return (.zero, CGSize(width: min(targetSize.width, titleFullSize.width), height: min(targetSize.height, titleFullSize.height)))
        }
        switch imagePosition {
        case .noImage:
            return (.zero, CGSize(width: min(targetSize.width, fullSize.width), height: min(targetSize.height, fullSize.height)))
        case .imageOnly:
            return (CGSize(width: min(targetSize.width, fullSize.width), height: min(targetSize.height, fullSize.height)), .zero)
        case .imageLeft, .imageRight, .imageLeading, .imageTrailing:
            let imageAndSpacing = imageFullSize.isZero ? 0 : (imageFullSize.width + spacing)
            if targetSize.width >= fullSize.width {
                return (CGSize(width: imageFullSize.width, height: min(targetSize.height, imageFullSize.height)), CGSize(width: titleFullSize.width, height: min(targetSize.height, titleFullSize.height)))
            } else if targetSize.width >= imageAndSpacing {
                return (CGSize(width: imageFullSize.width, height: min(targetSize.height, imageFullSize.height)), CGSize(width: targetSize.width - imageAndSpacing, height: min(targetSize.height, titleFullSize.height)))
            } else {
                return (CGSize(width: targetSize.width, height: min(targetSize.height, imageFullSize.height)), .zero)
            }
        case .imageBelow, .imageAbove:
            let imageAndSpacing = imageFullSize.isZero ? 0 : (imageFullSize.height + spacing)
            if targetSize.height >= fullSize.height {
                return (CGSize(width: min(targetSize.width, imageFullSize.width), height: imageFullSize.height), CGSize(width: min(targetSize.width, titleFullSize.width), height: titleFullSize.height))
            } else if targetSize.height >= imageAndSpacing {
                return (CGSize(width: min(targetSize.width, imageFullSize.width), height: imageFullSize.width), CGSize(width: min(targetSize.width, titleFullSize.width), height: targetSize.height - imageAndSpacing))
            } else {
                return (CGSize(width: min(targetSize.width, imageFullSize.width), height: targetSize.width), .zero)
            }
        case .imageOverlaps:
            return (CGSize(width: min(targetSize.width, imageFullSize.width), height: min(targetSize.height, imageFullSize.height)), CGSize(width: min(targetSize.width, titleFullSize.width), height: min(targetSize.height, titleFullSize.height)))
        @unknown default:
            return (CGSize(width: min(targetSize.width, imageFullSize.width), height: min(targetSize.height, imageFullSize.height)), CGSize(width: min(targetSize.width, titleFullSize.width), height: min(targetSize.height, titleFullSize.height)))
        }
    }
    
    
    /// 调整后image和title在tart中的偏移
    /// - Parameter rect: rect
    /// - Returns: res
    func resizeContentOffset(at rect: CGRect) -> (imageOffset: CGPoint, titleOffset: CGPoint) {
        let contentSize = resizeContentSize(at: rect)
        let resize = resizeImageAndTitleSize(at: rect)
        let imageSize = resize.imageSize
        let titleSize = resize.titleSize
        
        if imageSize.isZero, titleSize.isZero {
            return (.zero, .zero)
        }
        if imageSize.isZero {
            return (.zero, .zero)
        }
        if titleSize.isZero {
            return (.zero, .zero)
        }
        
        
        let imageLeft: (CGPoint, CGPoint) = (CGPoint(x: 0, y: imageSize.height > titleSize.height ? 0 : (titleSize.height - imageSize.height) / 2.0), CGPoint(x: imageSize.width + spacing, y: titleSize.height > imageSize.height ? 0 : (imageSize.height - titleSize.height) / 2.0))
        
        let imageRight: (CGPoint, CGPoint) = (CGPoint(x: titleSize.width + spacing, y: imageSize.height > titleSize.height ? 0 : (titleSize.height - imageSize.height) / 2.0), CGPoint(x: 0, y: titleSize.height > imageSize.height ? 0 : (imageSize.height - titleSize.height) / 2.0))
        
        switch imagePosition {
        case .noImage:
            return (.zero, .zero)
        case .imageOnly:
            return (.zero, .zero)
        case .imageAbove:
            switch alignment {
            case .left:
                return (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: imageSize.height + spacing))
            case .right:
                return (CGPoint(x: floor(contentSize.width - imageSize.width), y: 0), CGPoint(x: floor(contentSize.width - titleSize.width), y: imageSize.height + spacing))
            default:
                return (CGPoint(x: imageSize.width > titleSize.width ? 0 : (titleSize.width - imageSize.width) / 2.0, y: 0), CGPoint(x: titleSize.width > imageSize.width ? 0 : (titleSize.width - imageSize.width) / 2.0, y: imageSize.height + spacing))
            }
        case .imageBelow:
            switch alignment {
            case .left:
                return (CGPoint(x: 0, y: titleSize.height), CGPoint(x: 0, y: 0))
            case .right:
                return (CGPoint(x: floor(contentSize.width - imageSize.width), y: titleSize.height), CGPoint(x: floor(contentSize.width - titleSize.width), y: 0))
            default:
                return (CGPoint(x: imageSize.width > titleSize.width ? 0 : (titleSize.width - imageSize.width) / 2.0, y: titleSize.height + spacing), CGPoint(x: titleSize.width > imageSize.width ? 0 : (imageSize.width - titleSize.width) / 2.0, y: 0))
            }
        case .imageLeft:
            return imageLeft
        case .imageRight:
            return imageRight
        case .imageLeading:
            switch NSApplication.shared.userInterfaceLayoutDirection {
            case .leftToRight:
                return imageLeft
            case .rightToLeft:
                return imageRight
            @unknown default:
                fatalError()
            }
        case .imageTrailing:
            switch NSApplication.shared.userInterfaceLayoutDirection {
            case .leftToRight:
                return imageRight
            case .rightToLeft:
                return imageLeft
            @unknown default:
                fatalError()
            }
        case .imageOverlaps:
            return (CGPoint(x: imageSize.width > titleSize.width ? 0 : (titleSize.width - imageSize.width) / 2.0, y: imageSize.height > titleSize.height ? 0 : (titleSize.height - imageSize.height)  / 2.0), CGPoint(x: titleSize.width > imageSize.width ? 0 : (imageSize.width - titleSize.width) / 2.0, y: titleSize.height > imageSize.height ? 0 : (imageSize.height - titleSize.height) / 2.0))
        @unknown default:
            return (CGPoint(x: imageSize.width > titleSize.width ? 0 : (titleSize.width - imageSize.width) / 2.0, y: imageSize.height > titleSize.height ? 0 : (titleSize.height - imageSize.height)  / 2.0), CGPoint(x: titleSize.width > imageSize.width ? 0 : (imageSize.width - titleSize.width) / 2.0, y: titleSize.height > imageSize.height ? 0 : (imageSize.height - titleSize.height) / 2.0))
        }
    }
    
    
}

fileprivate extension CGSize {
    var isZero: Bool {
        width <= 0 || height <= 0
    }
    
    var alignment: CGSize {
        CGSize(width: ceil(width), height: ceil(height))
    }
    
    static func >= (l: CGSize, r: CGSize) -> Bool {
        return l.width >= r.width && l.height >= r.height
    }
}
