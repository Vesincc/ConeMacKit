//
//  File.swift
//
//
//  Created by HanQi on 2023/11/10.
//

import Foundation
import AppKit

public extension NSButton {
    
    func addTarget(_ target: Any?, action: Selector) {
        self.target = target as AnyObject?
        self.action = action
    }
    
    func replaceButtonCell(_ newCell: NSButtonCell) {
        let oldCell = cell as! NSButtonCell
        
        ///
        newCell.alternateTitle = oldCell.alternateTitle
        newCell.attributedAlternateTitle = oldCell.attributedAlternateTitle
        newCell.attributedTitle = oldCell.attributedTitle
        newCell.title = title
        newCell.alternateImage = oldCell.alternateImage
        newCell.imagePosition = oldCell.imagePosition
        newCell.imageScaling = oldCell.imageScaling
        newCell.keyEquivalent = oldCell.keyEquivalent
        newCell.keyEquivalentModifierMask = oldCell.keyEquivalentModifierMask
        newCell.backgroundColor = oldCell.backgroundColor
        newCell.bezelStyle = oldCell.bezelStyle
        newCell.imageDimsWhenDisabled = oldCell.imageDimsWhenDisabled
        newCell.isTransparent = oldCell.isTransparent
        newCell.showsBorderOnlyWhileMouseInside = oldCell.showsBorderOnlyWhileMouseInside
        newCell.highlightsBy = oldCell.highlightsBy
        newCell.sound = oldCell.sound
        newCell.image = oldCell.image
        
        /// nscell
        newCell.type = oldCell.type
        newCell.isEnabled = oldCell.isEnabled
        newCell.allowsUndo = oldCell.allowsUndo
        newCell.isBezeled = oldCell.isBezeled
        newCell.isBordered = oldCell.isBordered
        newCell.backgroundStyle = oldCell.backgroundStyle
        newCell.allowsMixedState = oldCell.allowsMixedState
        newCell.isEditable = oldCell.isEditable
        newCell.isSelectable = oldCell.isSelectable
        newCell.isScrollable = oldCell.isScrollable
        newCell.alignment = oldCell.alignment
        newCell.font = oldCell.font
        newCell.lineBreakMode = oldCell.lineBreakMode
        newCell.truncatesLastVisibleLine = oldCell.truncatesLastVisibleLine
        newCell.wraps = oldCell.wraps
        newCell.baseWritingDirection = oldCell.baseWritingDirection
        newCell.attributedStringValue = oldCell.attributedStringValue
        newCell.allowsEditingTextAttributes = oldCell.allowsEditingTextAttributes
        newCell.importsGraphics = oldCell.importsGraphics
        newCell.title = oldCell.title
        newCell.isContinuous = oldCell.isContinuous
        newCell.focusRingType = oldCell.focusRingType
        newCell.sendsActionOnEndEditing = oldCell.sendsActionOnEndEditing
        newCell.usesSingleLineMode = oldCell.usesSingleLineMode
        newCell.userInterfaceLayoutDirection = oldCell.userInterfaceLayoutDirection
        
        cell = newCell
    }
    
    
}
