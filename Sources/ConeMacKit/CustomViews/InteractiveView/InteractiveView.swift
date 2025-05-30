//
//  InteractiveView.swift
//
//
//  Created by HanQi on 2023/11/3.
//

import AppKit

open class InteractiveView: NSView, InteractiveViewProtocol {
 
    /// 是否向superview转发事件
    public var shouldForwardEventToSuperview: Bool = true
     
    public var backgroundColorEnable: Bool {
        true
    }
    
    public var interactiveBackgroundColors: [Interactive.State : NSColor] = [:]
    
    public var interactiveBorderColors: [Interactive.State : NSColor] = [:]
    
    public var interactiveBorderWidths: [Interactive.State : CGFloat] = [:]
    
    public var interactiveBlocks: [Interactive.State : () -> ()] = [:]
    
    public var interactiveCursors: [Interactive.State : NSCursor] = [:]
    
    public var interactiveEventActions: [Interactive.Event : ((Any?) -> ())?] = [:]
    
    
    public var interactiveState: Interactive.State = .normal
    
    public var isEnabled: Bool = true {
        didSet {
            isClicked = false
            fixState()
        }
    }
    
    public var isSelected: Bool = false {
        didSet {
            isClicked = false
            fixState()
        }
    }
    
    open var isEntered: Bool = false
    
    open var isClicked: Bool = false
    
    open var mouseTrackingArea: NSTrackingArea!
      
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initConfiger()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initConfiger()
    }
    
    private func initConfiger() {
        wantsLayer = true
        focusRingType = .none
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
        window?.invalidateCursorRects(for: self)
        let priority = statePriority(for: interactiveState)
        let backgroundColor = adapterValue(in: interactiveBackgroundColors, for: priority)
        let borderColor = adapterValue(in: interactiveBorderColors, for: priority)
        let borderWidth = adapterValue(in: interactiveBorderWidths, for: priority)
        let block = adapterValue(in: interactiveBlocks, for: priority)
        if backgroundColorEnable, let backgroundColor = backgroundColor {
            layer?.backgroundColor = backgroundColor.cgColor
        }
        layer?.borderColor = borderColor?.cgColor ?? layer?.borderColor
        layer?.borderWidth = borderWidth ?? layer?.borderWidth ?? 0
        block?()
        
    }
    
    open override func mouseEntered(with event: NSEvent) {
        interactiveMouseEntered(with: event)
    }
    
    open override func mouseExited(with event: NSEvent) {
        interactiveMouseExited(with: event)
    }
    
    open override func mouseDown(with event: NSEvent) {
        let local = convert(event.locationInWindow, from: nil)
        guard bounds.contains(local) else {
            return
        }
        interactiveMouseDownPrefix(with: event)
        if shouldForwardEventToSuperview {
            super.mouseDown(with: event)
        }
    }
    
    open override func mouseUp(with event: NSEvent) {
        let local = convert(event.locationInWindow, from: nil)
        guard bounds.contains(local) else {
            return
        }
        if isClicked {
            interactiveMouseDownSuffix(with: event)
        }
        if shouldForwardEventToSuperview {
            super.mouseUp(with: event)
        }
    }
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        isClicked = false
        updateMouseEnterExitTrackingArea()
    }
}
 
