//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation
import Cocoa

//fileprivate extension NSView {
//    
//    func wantsLayerIfNeed() {
//        if wantsLayer == false {
//            wantsLayer = true
//        }
//    }
//    
//}
//
//// MARK: - 圆角
//public extension NSView {
//    
//    
//    /// 圆角半径
//    @IBInspectable var cornerRadiusIB: CGFloat {
//        get {
//            return layer?.cornerRadius ?? 0
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.cornerRadius = newValue
//        }
//    }
//    
//    /// 左上角 默认 true
//    @IBInspectable var cornerTopLeftIB: Bool {
//        get {
//            layer?.maskedCorners.contains(.layerMinXMinYCorner) ?? true
//        }
//        set {
//            wantsLayerIfNeed()
//            if newValue {
//                layer?.maskedCorners.insert(.layerMinXMinYCorner)
//            } else {
//                layer?.maskedCorners.remove(.layerMinXMinYCorner)
//            }
//        }
//    }
//    
//    
//    /// 右上角 默认 true
//    @IBInspectable var cornerTopRightIB: Bool {
//        get {
//            layer?.maskedCorners.contains(.layerMaxXMinYCorner) ?? true
//        }
//        set {
//            wantsLayerIfNeed()
//            if newValue {
//                layer?.maskedCorners.insert(.layerMaxXMinYCorner)
//            } else {
//                layer?.maskedCorners.remove(.layerMaxXMinYCorner)
//            }
//        }
//    }
//    
//    /// 左下角 默认 true
//    @IBInspectable var cornerBottomLeftIB: Bool {
//        get {
//            layer?.maskedCorners.contains(.layerMinXMaxYCorner) ?? true
//        }
//        set {
//            wantsLayerIfNeed()
//            if newValue {
//                layer?.maskedCorners.insert(.layerMinXMaxYCorner)
//            } else {
//                layer?.maskedCorners.remove(.layerMinXMaxYCorner)
//            }
//        }
//    }
//    
//    
//    /// 右下角 默认 true
//    @IBInspectable var cornerBottomRightIB: Bool {
//        
//        get {
//            layer?.maskedCorners.contains(.layerMaxXMaxYCorner) ?? true
//        }
//        set {
//            wantsLayerIfNeed()
//            if newValue {
//                layer?.maskedCorners.insert(.layerMaxXMaxYCorner)
//            } else {
//                layer?.maskedCorners.remove(.layerMaxXMaxYCorner)
//            }
//        }
//    }
//     
//    
//}
//
//// MARK: - 边框
//public extension NSView {
//    
//    /// 边框粗细
//    @IBInspectable var borderWidthIB: CGFloat {
//        get {
//            return layer?.borderWidth ?? 0
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.borderWidth = newValue
//        }
//    }
//    
//    /// 边框颜色
//    @IBInspectable var borderColorIB: NSColor? {
//        get {
//            guard let color = layer?.borderColor else {
//                return nil
//            }
//            return NSColor(cgColor: color)
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.borderColor = newValue?.cgColor
//        }
//    }
//    
//    
//}
//
//
//// MARK: - 阴影
//public extension NSView {
//    
//    /// 阴影偏移
//    @IBInspectable var shadowOffsetIB: CGSize {
//        get {
//            return layer?.shadowOffset ?? .zero
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.shadowOffset = newValue
//        }
//    }
//    
//    /// 阴影半径
//    @IBInspectable var shadowRadiusIB: CGFloat {
//        get {
//            return layer?.shadowRadius ?? 0
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.shadowRadius = newValue
//        }
//    }
//    
//    /// 阴影透明度
//    @IBInspectable var shadowOpacityIB: Float {
//        get {
//            return layer?.shadowOpacity ?? 0
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.shadowOpacity = newValue
//        }
//    }
//    
//    /// 阴影颜色
//    @IBInspectable var shadowColorIB: NSColor? {
//        get {
//            guard let color = layer?.shadowColor else {
//                return nil
//            }
//            return NSColor(cgColor: color)
//        }
//        set {
//            layer?.shadowColor = newValue?.cgColor
//        }
//    }
//}
//
//
//// MARK: - 背景
//public extension NSView {
//    
//    @IBInspectable var backgroundColorIB: NSColor? {
//        get {
//            guard let color = layer?.backgroundColor else {
//                return nil
//            }
//            return NSColor(cgColor: color)
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.backgroundColor = newValue?.cgColor
//        }
//    }
//    
//    @IBInspectable var isClip: Bool {
//        get {
//            layer?.masksToBounds ?? false
//        }
//        set {
//            wantsLayerIfNeed()
//            layer?.masksToBounds = newValue
//        }
//    }
//    
//}
//
//// MARK: - 背景
//public extension NSWindow {
//    
//    @IBInspectable var backgroundColorIB: NSColor? {
//        get {
//            backgroundColor
//        }
//        set {
//            backgroundColor = newValue
//        }
//    }
//    
//}
//
//// MARK: - NSTextField
//public extension NSTextField {
//    
//    fileprivate static var _placeholderColor = 0
//    @IBInspectable var localizedKeyIB: String? {
//        set {
//            guard let newValue = newValue else { return }
//            stringValue = NSLocalizedString(newValue, comment: "")
//        }
//        get { return stringValue }
//    }
//    
//    @IBInspectable var placeholderLocalizedKeyIB: String? {
//        set {
//            guard let newValue = newValue else { return }
//            placeholderString = NSLocalizedString(newValue, comment: "")
//            if let color = placeholderColorIB {
//                let str = NSAttributedString(string: NSLocalizedString(newValue, comment: ""), attributes: [
//                    NSAttributedString.Key.foregroundColor : color,
//                    NSAttributedString.Key.font : font ?? NSFont.systemFont(ofSize: 14)
//                ])
//                placeholderString = nil
//                placeholderAttributedString = str
//            }
//        }
//        get { return stringValue }
//    }
//    
//    @IBInspectable var placeholderColorIB: NSColor? {
//        get {
//            objc_getAssociatedObject(self, &NSTextField._placeholderColor) as? NSColor
//        }
//        set {
//            objc_setAssociatedObject(self, &NSTextField._placeholderColor, newValue, .OBJC_ASSOCIATION_COPY)
//            if let color = newValue, let str = placeholderString, !str.isEmpty {
//                let aStr = NSAttributedString(string: NSLocalizedString(str, comment: ""), attributes: [
//                    NSAttributedString.Key.foregroundColor : color,
//                    NSAttributedString.Key.font : font ?? NSFont.systemFont(ofSize: 14)
//                ])
//                placeholderString = nil
//                placeholderAttributedString = aStr
//            }
//        }
//    }
//    
//}
//
//
//public extension NSMenuItem {
//    
//    @IBInspectable var localizedKeyIB: String? {
//        set {
//            guard let newValue = newValue else { return }
//            title = NSLocalizedString(newValue, comment: "")
//        }
//        get { return title }
//    }
//}
//
//
//
//// MARK: - InteractiveView
//public extension InteractiveView {
//    
//    // MARK: - normal
//    @IBInspectable var normalBackgroundColor: NSColor? {
//        get {
//            backgroundColor(for: .normal)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBackgroundColor(newValue, for: .normal)
//        }
//    }
//    
//    @IBInspectable var normalBorderColor: NSColor? {
//        get {
//            borderColor(for: .normal)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBorderColor(newValue, for: .normal)
//        }
//    }
//    
//     
//    // MARK: - hovered
//    @IBInspectable var hoveredBackgroundColor: NSColor? {
//        get {
//            backgroundColor(for: .hovered)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBackgroundColor(newValue, for: .hovered)
//        }
//    }
//    
//    @IBInspectable var hoveredBorderColor: NSColor? {
//        get {
//            borderColor(for: .hovered)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBorderColor(newValue, for: .hovered)
//        }
//    }
//    
//    // MARK: - clicked
//    @IBInspectable var clickedBackgroundColor: NSColor? {
//        get {
//            backgroundColor(for: .clicked)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBackgroundColor(newValue, for: .clicked)
//        }
//    }
//    
//    @IBInspectable var clickedBorderColor: NSColor? {
//        get {
//            borderColor(for: .clicked)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBorderColor(newValue, for: .clicked)
//        }
//    }
//    
//}
//
//
//// MARK: - GradientView
//public extension GradientView {
//    
//    
//    @IBInspectable var isHorizontalDirection: Bool {
//        get {
//            direction == .horizontal
//        }
//        set {
//            if newValue {
//                direction = .horizontal
//            }
//        }
//    }
//    
//    @IBInspectable var isVerticalDirection: Bool {
//        get {
//            direction == .vertical
//        }
//        set {
//            if newValue {
//                direction = .vertical
//            }
//        }
//    }
//    
//    @IBInspectable var isObliqueUpwardDirection: Bool {
//        get {
//            direction == .obliqueUpward
//        }
//        set {
//            if newValue {
//                direction = .obliqueUpward
//            }
//        }
//    }
//    
//    @IBInspectable var isObliqueDescentDirection: Bool {
//        get {
//            direction == .obliqueDescent
//        }
//        set {
//            if newValue {
//                direction = .obliqueDescent
//            }
//        }
//    }
//    
//
//    // MARK: - normal
//    @IBInspectable var normalStartColor: NSColor? {
//        get {
//            colors(for: .normal)?.first
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .normal) ?? []
//            colors.insert(newValue, at: 0)
//            setColors(colors, for: .normal)
//        }
//    }
//    
//    
//    @IBInspectable var normalEndColor: NSColor? {
//        get {
//            colors(for: .normal)?.last
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .normal) ?? []
//            colors.append(newValue)
//            setColors(colors, for: .normal)
//        }
//    }
//    
//    
//    // MARK: - hoverd
//    @IBInspectable var hoveredStartColor: NSColor? {
//        get {
//            colors(for: .hovered)?.first
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .hovered) ?? []
//            colors.insert(newValue, at: 0)
//            setColors(colors, for: .hovered)
//        }
//    }
//    
//    
//    @IBInspectable var hoveredEndColor: NSColor? {
//        get {
//            colors(for: .hovered)?.last
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .hovered) ?? []
//            colors.append(newValue)
//            setColors(colors, for: .hovered)
//        }
//    }
//    
//    
//    // MARK: - clicked
//    @IBInspectable var clickedStartColor: NSColor? {
//        get {
//            colors(for: .clicked)?.first
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .clicked) ?? []
//            colors.insert(newValue, at: 0)
//            setColors(colors, for: .clicked)
//        }
//    }
//    
//    
//    @IBInspectable var clickedEndColor: NSColor? {
//        get {
//            colors(for: .clicked)?.last
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .clicked) ?? []
//            colors.append(newValue)
//            setColors(colors, for: .clicked)
//        }
//    }
//}
//
//
//// MARK: - InteractiveButton
//public extension InteractiveButton {
//    
//    // MARK: - normal
//    @IBInspectable var nomalLocalizedKey: String? {
//        get {
//            text(for: .normal)
//        }
//        set {
//            setText(NSLocalizedString(newValue ?? "", comment: ""), for: .normal)
//        }
//    }
//    
////    @IBInspectable var nomalText: String? {
////        get {
////            text(for: .normal)
////        }
////        set {
////            setText(newValue, for: .normal)
////        }
////    }
//    
//    @IBInspectable var normalTextColor: NSColor? {
//        get {
//            textColor(for: .normal)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setTextColor(newValue, for: .normal)
//        }
//    }
//    
//    @IBInspectable var normalImage: NSImage? {
//        get {
//            image(for: .normal)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setImage(newValue, for: .normal)
//        }
//    }
//    
//    @IBInspectable var normalBackgroundColor: NSColor? {
//        get {
//            backgroundColor(for: .normal)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBackgroundColor(newValue, for: .normal)
//        }
//    }
//    
//    @IBInspectable var normalBorderColor: NSColor? {
//        get {
//            borderColor(for: .normal)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBorderColor(newValue, for: .normal)
//        }
//    }
//    
//    
//    // MARK: - hovered
//    @IBInspectable var hoveredLocalizedKey: String? {
//        get {
//            text(for: .hovered)
//        }
//        set {
//            setText(NSLocalizedString(newValue ?? "", comment: ""), for: .hovered)
//        }
//    }
//
////    @IBInspectable var hoverText: String {
////        get {
////            text(for: .hover)
////        }
////        set {
////            setText(newValue, for: .hover)
////        }
////    }
//    
//    @IBInspectable var hoveredTextColor: NSColor? {
//        get {
//            textColor(for: .hovered)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setTextColor(newValue, for: .hovered)
//        }
//    }
//    
//    @IBInspectable var hoveredImage: NSImage? {
//        get {
//            image(for: .hovered)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setImage(newValue, for: .hovered)
//        }
//    }
//    
//    @IBInspectable var hoveredBackgroundColor: NSColor? {
//        get {
//            backgroundColor(for: .hovered)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBackgroundColor(newValue, for: .hovered)
//        }
//    }
//    
//    @IBInspectable var hoveredBorderColor: NSColor? {
//        get {
//            borderColor(for: .hovered)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBorderColor(newValue, for: .hovered)
//        }
//    }
//    
//    
//    // MARK: - clicked
//    @IBInspectable var clickedLocalizedKey: String? {
//        get {
//            text(for: .clicked)
//        }
//        set {
//            setText(NSLocalizedString(newValue ?? "", comment: ""), for: .clicked)
//        }
//    }
//    
////    @IBInspectable var clickText: String {
////        get {
////            text(for: .click)
////        }
////        set {
////            setText(newValue, for: .click)
////        }
////    }
//    
//    @IBInspectable var clickedTextColor: NSColor? {
//        get {
//            textColor(for: .clicked)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setTextColor(newValue, for: .clicked)
//        }
//    }
//    
//    @IBInspectable var clickedImage: NSImage? {
//        get {
//            image(for: .clicked)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setImage(newValue, for: .clicked)
//        }
//    }
//    
//    @IBInspectable var clickedBackgroundColor: NSColor? {
//        get {
//            backgroundColor(for: .clicked)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBackgroundColor(newValue, for: .clicked)
//        }
//    }
//    
//    @IBInspectable var clickedBorderColor: NSColor? {
//        get {
//            borderColor(for: .clicked)
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            setBorderColor(newValue, for: .clicked)
//        }
//    }
//}
//
//
//// MARK: - GradientButton
//public extension GradientButton {
//    
//    
//    @IBInspectable var isHorizontalDirection: Bool {
//        get {
//            direction == .horizontal
//        }
//        set {
//            if newValue {
//                direction = .horizontal
//            }
//        }
//    }
//    
//    @IBInspectable var isVerticalDirection: Bool {
//        get {
//            direction == .vertical
//        }
//        set {
//            if newValue {
//                direction = .vertical
//            }
//        }
//    }
//    
//    @IBInspectable var isObliqueUpwardDirection: Bool {
//        get {
//            direction == .obliqueUpward
//        }
//        set {
//            if newValue {
//                direction = .obliqueUpward
//            }
//        }
//    }
//    
//    @IBInspectable var isObliqueDescentDirection: Bool {
//        get {
//            direction == .obliqueDescent
//        }
//        set {
//            if newValue {
//                direction = .obliqueDescent
//            }
//        }
//    }
//    
//
//    // MARK: - normal
//    @IBInspectable var normalStartColor: NSColor? {
//        get {
//            colors(for: .normal)?.first
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .normal) ?? []
//            colors.insert(newValue, at: 0)
//            setColors(colors, for: .normal)
//        }
//    }
//    
//    
//    @IBInspectable var normalEndColor: NSColor? {
//        get {
//            colors(for: .normal)?.last
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .normal) ?? []
//            colors.append(newValue)
//            setColors(colors, for: .normal)
//        }
//    }
//    
//    
//    // MARK: - hoverd
//    @IBInspectable var hoveredStartColor: NSColor? {
//        get {
//            colors(for: .hovered)?.first
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .hovered) ?? []
//            colors.insert(newValue, at: 0)
//            setColors(colors, for: .hovered)
//        }
//    }
//    
//    
//    @IBInspectable var hoveredEndColor: NSColor? {
//        get {
//            colors(for: .hovered)?.last
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .hovered) ?? []
//            colors.append(newValue)
//            setColors(colors, for: .hovered)
//        }
//    }
//    
//    
//    // MARK: - clicked
//    @IBInspectable var clickedStartColor: NSColor? {
//        get {
//            colors(for: .clicked)?.first
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .clicked) ?? []
//            colors.insert(newValue, at: 0)
//            setColors(colors, for: .clicked)
//        }
//    }
//    
//    
//    @IBInspectable var clickedEndColor: NSColor? {
//        get {
//            colors(for: .clicked)?.last
//        }
//        set {
//            guard let newValue = newValue else {
//                return
//            }
//            var colors = colors(for: .clicked) ?? []
//            colors.append(newValue)
//            setColors(colors, for: .clicked)
//        }
//    }
//}
