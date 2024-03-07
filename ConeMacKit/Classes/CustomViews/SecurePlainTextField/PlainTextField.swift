//
//  PlainTextField.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/2/20.
//

import Cocoa

open class PlainTextField: NSTextField {
    
    @IBInspectable public var insertionPointColor: NSColor? {
        get {
            insertionPointColorValue
        }
        set {
            insertionPointColorValue = newValue
        }
    }
    
    fileprivate var insertionPointColorValue: NSColor?
    
    open var willBecomeFirstResponder: (() -> ())?
     
    open var didBecomeFirstResponder: (() -> ())?
    
    open override func becomeFirstResponder() -> Bool {
        willBecomeFirstResponder?()
        let success = super.becomeFirstResponder()
        if success {
            if let color = insertionPointColorValue {
                (currentEditor() as? NSTextView)?.insertionPointColor = color
            }
            didBecomeFirstResponder?()
        }
        return success
    }
    
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configers()
    }
    
    func configers() {
        focusRingType = .none
    }
    
    
    public func clearSelect() {
        let str = self.cell?.stringValue ?? ""
        selectText(NSRange(location: str.count, length: 0))
    }
    
    public func selectText(_ range: NSRange) {
        if let textEditor = window?.fieldEditor(true, for: self) {
            let cell = selectedCell()
            cell?.select(withFrame: bounds, in: self, editor: textEditor, delegate: self, start: range.location, length: range.location)
        }
    }
}
