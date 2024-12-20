//
//  File.swift
//
//
//  Created by HanQi on 2023/11/3.
//

import Foundation
import AppKit

open class InteractiveButton: NSButton, InteractiveButtonProtocol {
     
    
    public var backgroundColorEnable: Bool {
        true
    }
    
    public var interactiveHiddenImageAndText: [Interactive.State : (imageHidden: Bool, textHidden: Bool)] = [:]
    
    public var interactiveTexts: [Interactive.State : String] = [:]
    
    public var interactiveTextColors: [Interactive.State : NSColor] = [:]
    
    public var interactiveAttributedTexts: [Interactive.State : NSAttributedString] = [:]
    
    public var interactiveImages: [Interactive.State : NSImage?] = [:]
    
    public var interactiveFonts: [Interactive.State : NSFont] = [:]
    
    public var interactiveBlocks: [Interactive.State : () -> ()] = [:]
    
    public var interactiveBackgroundColors: [Interactive.State : NSColor] = [:]
    
    public var interactiveBorderColors: [Interactive.State : NSColor] = [:]
    
    public var interactiveBorderWidths: [Interactive.State : CGFloat] = [:]
    
    public var interactiveCursors: [Interactive.State : NSCursor] = [:]
    
    public var interactiveEventActions: [Interactive.Event : ((Any?) -> ())?] = [:]
    
    
    public var interactiveState: Interactive.State = .normal
    
    public override var isEnabled: Bool  {
        get {
            _isEnabled
        }
        set {
            _isEnabled = newValue
            isClicked = false
            fixState()
        }
    }
    private var _isEnabled = true
    
    public var isSelected: Bool = false {
        didSet {
            isClicked = false
            fixState()
        }
    }
    
    public var isEntered: Bool = false
    
    public var isClicked: Bool = false
    
    public var mouseTrackingArea: NSTrackingArea!
    
    
    private var isInteractiveStateDidChanged = false
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initConfiger()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        if super.isEnabled == false {
            super.isEnabled = true
            isEnabled = false
        }
        initConfiger()
    }
     
    
    private func initConfiger() {
        wantsLayer = true
        focusRingType = .none
        isBordered = false
        (cell as? NSButtonCell)?.highlightsBy = NSCell.StyleMask(rawValue: 0)
        (cell as? NSButtonCell)?.imageDimsWhenDisabled = false
    }
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        updateMouseEnterExitTrackingArea()
    }
    
    open override func resetCursorRects() {
        super.resetCursorRects()
        let priority = statePriority(for: interactiveState)
        if let cursor = adapterValue(in: interactiveCursors, for: priority) {
            addCursorRect(bounds, cursor: cursor)
        }
    }
    
    open func interactiveStateDidChanged(lastState: Interactive.State) {
        let priority = statePriority(for: interactiveState)
        if adapterValue(in: interactiveCursors, for: priority) != nil {
            window?.invalidateCursorRects(for: self)
        }
        let backgroundColor = adapterValue(in: interactiveBackgroundColors, for: priority)
        let borderColor = adapterValue(in: interactiveBorderColors, for: priority)
        let borderWidth = adapterValue(in: interactiveBorderWidths, for: priority)
        
        let hiddenImageAndText = adapterValue(in: interactiveHiddenImageAndText, for: priority) ?? (false, false)
        var text = adapterValue(in: interactiveTexts, for: priority) ?? title
        var image = adapterValue(in: interactiveImages, for: priority) ?? self.image
        if hiddenImageAndText.imageHidden {
            image = nil
        }
        if hiddenImageAndText.textHidden {
            text = ""
        }
        
        let attributedText = adapterValue(in: interactiveAttributedTexts, for: priority)
        let textColor = adapterValue(in: interactiveTextColors, for: priority) ?? .black
        let font = adapterValue(in: interactiveFonts, for: priority) ?? self.font ?? NSFont.systemFont(ofSize: 14)
        let block = adapterValue(in: interactiveBlocks, for: priority)
        
        if backgroundColorEnable {
            layer?.backgroundColor = backgroundColor?.cgColor
        }
        layer?.borderColor = borderColor?.cgColor ?? layer?.borderColor
        layer?.borderWidth = borderWidth ?? layer?.borderWidth ?? 0
        if let attributedText = attributedText {
            self.attributedTitle = attributedText
        } else {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = alignment
            let str = NSAttributedString(string: text, attributes: [
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : textColor,
                NSAttributedString.Key.paragraphStyle : paragraph
            ])
            self.attributedTitle = str
        }
        self.image = image ?? nil
        block?()
    }
    
    
    open override func mouseEntered(with event: NSEvent) {
        interactiveMouseEntered(with: event)
    }
    
    open override func mouseExited(with event: NSEvent) {
        interactiveMouseExited(with: event)
    }
    
    open override func mouseDown(with event: NSEvent) {
        interactiveMouseDownPrefix(with: event)
        if isEnabled {
            super.mouseDown(with: event)
        }
        interactiveMouseDownSuffix(with: event)
    }
    
    open override func mouseUp(with event: NSEvent) {
    }
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        isClicked = false
        updateMouseEnterExitTrackingArea()
    }
}
