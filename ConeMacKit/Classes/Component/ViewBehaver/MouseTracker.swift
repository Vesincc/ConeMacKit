//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/2.
//

import Foundation
import Cocoa


// MARK: - 自定义view
public protocol MouseTrackingProtocol: NSView {
    var mouseTrackingArea: NSTrackingArea! { get set }
}

public extension MouseTrackingProtocol {
    func configerTrackingArea() {
        mouseTrackingArea = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(mouseTrackingArea)
        
        if var mouseLocation = window?.mouseLocationOutsideOfEventStream {
            mouseLocation = convert(mouseLocation, from: nil)
            if bounds.contains(mouseLocation) {
                mouseEntered(with: NSEvent())
            } else {
                mouseExited(with: NSEvent())
            }
        } 
    }
    
    func updateMouseEnterExitTrackingArea() {
        if let mouseTrackingArea = mouseTrackingArea {
            removeTrackingArea(mouseTrackingArea)
        }
        configerTrackingArea()
    }
}


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

fileprivate var t_mouseTracker: Int = 0
extension ViewBehaverWrapper: MouseTrackerProvider where Base : NSView {
    
    public var mouseTracker: MouseTrackable {
        guard let tracker = objc_getAssociatedObject(base, &t_mouseTracker) as? MouseTrackable else {
            let tracker = MouseTracker()
            objc_setAssociatedObject(base, &t_mouseTracker, tracker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            base.updateTrackingAreaAssociated.append { [weak base] in
                guard let base = base else {
                    return
                }
                tracker.updateTrackingArea(base)
            }
            base.mouseEnteredAssociated.append { _ in
                tracker.recive(.entered)
            }
            base.mouseExitedAssociated.append { _ in
                tracker.recive(.exited)
            }
            return tracker
        }
        return tracker
    }
     
}
