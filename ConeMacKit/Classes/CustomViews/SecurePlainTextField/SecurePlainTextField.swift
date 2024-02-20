//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/10.
//

import Foundation
import Cocoa

open class SecurePlainTextField: NSSecureTextField {
     
    /// 是否密文输入
    open var isSecureTextEntry: Bool = true {
        didSet {
            updatePasswrodCell()
        }
    }
     
    @IBInspectable var insertionPointColor: NSColor? {
        get {
            insertionPointColorValue
        }
        set {
            insertionPointColorValue = newValue
        }
    }
    
    fileprivate var insertionPointColorValue: NSColor?
     
    open var didBecomeFirstResponder: (() -> ())?
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if success {
            if let color = insertionPointColorValue {
                (currentEditor() as? NSTextView)?.insertionPointColor = color
            }
            didBecomeFirstResponder?()
        }
        return success
    }
     
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configers()
    }
    
    
    func configers() {
        focusRingType = .none
        let oldCell: NSTextFieldCell = self.cell as! NSTextFieldCell
        let newCell: NSTextFieldCell = CenterSecureTextFieldCell()
        updateCell(oldCell: oldCell, newCell: newCell)
    }
    
    func updateCell(oldCell: NSTextFieldCell, newCell: NSTextFieldCell) {
        /// NSTextFieldCell
        newCell.textColor = oldCell.textColor
        newCell.bezelStyle = oldCell.bezelStyle
        newCell.backgroundColor = oldCell.backgroundColor
        newCell.drawsBackground = oldCell.drawsBackground
        newCell.placeholderString = oldCell.placeholderString
        newCell.placeholderAttributedString = oldCell.placeholderAttributedString
        newCell.allowedInputSourceLocales = oldCell.allowedInputSourceLocales
        
        /// NSActionCell
        newCell.action = oldCell.action
        newCell.target = oldCell.target
        newCell.tag = oldCell.tag
        
        /// NSCell
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
         
        self.cell = newCell
    }
    
    
    
    func updatePasswrodCell() {
        let str = self.cell?.stringValue ?? ""
        
        var isEdit = false
        if self.window?.firstResponder == self.currentEditor() {
            // Text field has focus.
            abortEditing()
            isEdit = true
        }
        
        let newCell: NSTextFieldCell!
        let oldCell: NSTextFieldCell = self.cell as! NSTextFieldCell
        
        if isSecureTextEntry {
            newCell = CenterSecureTextFieldCell()
        } else {
            newCell = CenterTextFieldCell()
        }
        updateCell(oldCell: oldCell, newCell: newCell)
        
        self.cell?.stringValue = str
        self.needsUpdateConstraints = true
        self.needsLayout = true
        self.needsDisplay = true
        
        if isEdit {
            selectText(NSRange(location: str.count, length: 0))
        }
    }
    
    
    func selectText(_ range: NSRange) {
        if let textEditor = window?.fieldEditor(true, for: self) {
            let cell = selectedCell()
            cell?.select(withFrame: bounds, in: self, editor: textEditor, delegate: self, start: range.location, length: range.location)
        }
    }
    
}
