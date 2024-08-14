//
//  File.swift
//  
//
//  Created by HanQi on 2024/8/14.
//

import AppKit

public protocol MouseEventable {
    func subscribeMouseEvent(_ block: ((Interactive.Event) -> ())?)
}

class MouseEventor: MouseEventable {
    func subscribeMouseEvent(_ block: ((Interactive.Event) -> ())?) {
        self.observer = block
    }
    private var observer: ((Interactive.Event) -> ())?
    
    private var event: Interactive.Event = .mouseDown {
        didSet {
            observer?(event)
        }
    }
    func recive(_ event: Interactive.Event) {
        self.event = event
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
            mouseEvent.recive(.mouseDown)
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
            if bounds.contains(location) {
                mouseEvent.recive(.mouseUpInside)
            } else {
                mouseEvent.recive(.mouseUpOutside)
            }
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
