//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation
import Cocoa

class CenterSecureTextFieldCell: NSSecureTextFieldCell {
    
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        var newRect:NSRect = super.drawingRect(forBounds: theRect)
        let textSize:NSSize = self.cellSize(forBounds: theRect)
        let heightDelta:CGFloat = newRect.size.height - textSize.height
        if heightDelta > 0 {
            newRect.size.height = textSize.height
            newRect.origin.y += heightDelta * 0.5
        }
        return newRect
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let arect = self.drawingRect(forBounds: rect)
        super.select(withFrame: arect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }

    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let aRect = self.drawingRect(forBounds: rect)
        super.edit(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
}
