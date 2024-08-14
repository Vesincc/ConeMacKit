//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/2.
//

import Foundation
import AppKit
  
// MARK: - NSView直接track

public enum MouseTrackEvent {
    case entered
    case exited 
}

public protocol MouseTrackable {
    func subscribeMouseTrackEvent(_ block: ((MouseTrackEvent) -> ())?)
}

public class MouseTracker: MouseTrackable {
     
    var _trackingArea: NSTrackingArea?
    func updateTrackingArea(_ view: NSView) {
        if let _trackingArea = _trackingArea {
            view.removeTrackingArea(_trackingArea)
        }
        _trackingArea = NSTrackingArea(rect: view.bounds,
                                       options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved],
              owner: view,
              userInfo: nil)
        view.addTrackingArea(_trackingArea!)
        if var mouseLocation = view.window?.mouseLocationOutsideOfEventStream {
            mouseLocation = view.convert(mouseLocation, from: nil)
            if view.bounds.contains(mouseLocation) {
                event = .entered
            } else {
                event = .exited
            }
        }
    }
    
    private var observer: ((MouseTrackEvent) -> ())?
    
    private var event: MouseTrackEvent = .exited {
        didSet {
            observer?(event)
        }
    }
    
    public func subscribeMouseTrackEvent(_ observer: ((MouseTrackEvent) -> ())?) {
        self.observer = observer
    }
    
    func recive(_ event: MouseTrackEvent) {
        self.event = event
    }
}

public protocol MouseTrackerProvider {
    var mouseTracker: MouseTrackable { get }
}
 
open class ViewBehaverMouseTrackerView: NSView, MouseTrackerProvider {
    public var mouseTracker: MouseTrackable = MouseTracker()
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configerViews()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    func configerViews() {
        if let tracker = mouseTracker as? MouseTracker {
            tracker.updateTrackingArea(self)
        }
    }
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        guard let tracker = mouseTracker as? MouseTracker else {
            return
        }
        tracker.updateTrackingArea(self)
    }
    open override func mouseEntered(with event: NSEvent) {
        if let tracker = mouseTracker as? MouseTracker {
            tracker.recive(.entered)
        }
    }
    open override func mouseExited(with event: NSEvent) {
        if let tracker = mouseTracker as? MouseTracker {
            tracker.recive(.exited)
        }
    }
    open override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}
 
public extension ViewBehaverWrapper where Base : NSView {
    
    var mouseTracker: MouseTrackable {
        if let trackerView = base.subviews.first(where: { $0 is ViewBehaverMouseTrackerView }) as? ViewBehaverMouseTrackerView {
            return trackerView.mouseTracker
        }
        let new = ViewBehaverMouseTrackerView()
        new.translatesAutoresizingMaskIntoConstraints = false
        base.addSubview(new)
        NSLayoutConstraint.activate([
            new.topAnchor.constraint(equalTo: base.topAnchor),
            new.bottomAnchor.constraint(equalTo: base.bottomAnchor),
            new.leftAnchor.constraint(equalTo: base.leftAnchor),
            new.rightAnchor.constraint(equalTo: base.rightAnchor)
        ])
        return new.mouseTracker
    }
    
    
}


fileprivate var _trackingAreasTemporary = 0
public extension NSView {
    private var trackingAreasTemporary: [NSTrackingArea] {
        get {
            objc_getAssociatedObject(self, &_trackingAreasTemporary) as? [NSTrackingArea] ?? []
        }
        set {
            objc_setAssociatedObject(self, &_trackingAreasTemporary, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func removeTrackingAreasTemporary() {
        var temp = trackingAreasTemporary
        temp.append(contentsOf: trackingAreas)
        trackingAreasTemporary = temp
        trackingAreas.forEach({ removeTrackingArea($0) })
        
        subviews.forEach({ $0.removeTrackingAreasTemporary() } )
    }
    
    func restoreTrackingAreas() {
        let temp = trackingAreasTemporary
        trackingAreasTemporary = []
        temp.forEach({ addTrackingArea($0) })
        
        subviews.forEach({ $0.restoreTrackingAreas() } )
    }
}
