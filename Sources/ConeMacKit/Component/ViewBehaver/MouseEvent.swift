//
//  File.swift
//
//
//  Created by HanQi on 2024/8/14.
//

import AppKit

public protocol MouseEventable {
    
    /// 是否向superview转发事件
    var shouldForwardEventToSuperview: Bool { get set }
    
    /// 订阅事件
    /// - Parameter block: 事件类型
    func subscribeMouseEvent(_ block: ((Interactive.Event) -> ())?)
}

class MouseEventor: MouseEventable {
    var shouldForwardEventToSuperview: Bool = false
    
    func subscribeMouseEvent(_ block: ((Interactive.Event) -> ())?) {
        self.observer = block
    }
    private var observer: ((Interactive.Event) -> ())?
    
    private var event: Interactive.Event = .mouseDown {
        didSet {
            observer?(event)
        }
    }
    
    
    /// 接收事件
    /// - Parameter event: event
    /// - Returns: 是否向superview转发
    @discardableResult
    func recive(_ event: Interactive.Event) -> Bool {
        if observer != nil {
            self.event = event
            return shouldForwardEventToSuperview
        } else {
            return true
        }
    }
}

public protocol MouseEventProvider {
    var mouseEvent: MouseEventable { get }
}

open class ViewBehaverMouseEventView: NSView, MouseEventProvider {
    public var mouseEvent: any MouseEventable = MouseEventor()
    
    var isMouseDown = false
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configerViews()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    open override func mouseDown(with event: NSEvent) {
        if let mouseEvent = mouseEvent as? MouseEventor {
            let canForwardEventToSuperview = mouseEvent.recive(.mouseDown)
            if canForwardEventToSuperview {
                super.mouseDown(with: event)
            }
        } else {
            super.mouseDown(with: event)
        }
        isMouseDown = true
    }
    open override func mouseUp(with event: NSEvent) {
        guard isMouseDown else {
            return
        }
        isMouseDown = false
        let location = convert(event.locationInWindow, from: nil)
        if let mouseEvent = mouseEvent as? MouseEventor {
            var canForwardEventToSuperview = false
            if bounds.contains(location) {
                canForwardEventToSuperview = mouseEvent.recive(.mouseUpInside)
            } else {
                canForwardEventToSuperview = mouseEvent.recive(.mouseUpOutside)
            }
            if canForwardEventToSuperview {
                super.mouseUp(with: event)
            }
        } else {
            super.mouseUp(with: event)
        }
    }
    func configerViews() {
    }
}
 
public extension ViewBehaverWrapper where Base : NSView {
    
    var mouseEvent: MouseEventable {
        if let eventView = base.subviews.first(where: { $0 is ViewBehaverMouseEventView }) as? ViewBehaverMouseEventView {
            return eventView.mouseEvent
        }
        let new = ViewBehaverMouseEventView()
        new.translatesAutoresizingMaskIntoConstraints = false
        base.addSubview(new)
        NSLayoutConstraint.activate([
            new.topAnchor.constraint(equalTo: base.topAnchor),
            new.bottomAnchor.constraint(equalTo: base.bottomAnchor),
            new.leftAnchor.constraint(equalTo: base.leftAnchor),
            new.rightAnchor.constraint(equalTo: base.rightAnchor)
        ])
        return new.mouseEvent
    }
     
}
