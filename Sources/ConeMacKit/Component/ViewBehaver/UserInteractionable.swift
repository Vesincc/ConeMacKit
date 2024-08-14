//
//  File.swift
//  
//
//  Created by HanQi on 2023/12/22.
//

import Foundation
import AppKit

open class ViewBehaverDisableUserInteractionView: NSView {
    var localMonitor: Any?
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configerViews()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    deinit {
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        localMonitor = nil
    }
    func configerViews() {
        wantsLayer = true
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseEntered, .mouseExited]) { [weak self] event in
            guard let self = self else {
                return event
            }
            var collections: [NSView] = [self]
            if let superView = self.superview {
                collections.append(superView)
                collections.append(contentsOf: superView.subviews)
            }
            if event.type == .mouseEntered || event.type == .mouseExited {
                if let view = event.trackingArea?.owner as? NSView, collections.contains(view) {
                    return nil
                }
            } 
            return event
        }
    }
    open override func mouseDown(with event: NSEvent) {
    }
    open override func mouseUp(with event: NSEvent) {
    }
    open override func hitTest(_ point: NSPoint) -> NSView? {
        let location = convert(point, from: superview)
        if bounds.contains(location) {
            return self
        } else {
            return super.hitTest(point)
        }
    }
}

public protocol UserInteractionable {
    var isUserInteractionEnabled: Bool { get set }
} 

extension ViewBehaverWrapper: UserInteractionable where Base: NSView {
    public var isUserInteractionEnabled: Bool {
        get {
            !base.subviews.contains(where: { $0 is ViewBehaverDisableUserInteractionView })
        }
        set {
            setUserInteractionEnable(newValue)
        }
    }
    
    public func setUserInteractionEnable(_ isEnable: Bool, color: NSColor? = .clear) {
        let disableView = base.subviews.first(where: { $0 is ViewBehaverDisableUserInteractionView })
        if !isEnable {
            if let disableView = disableView {
                disableView.layer?.backgroundColor = color?.cgColor
            } else {
                let new = ViewBehaverDisableUserInteractionView()
                new.translatesAutoresizingMaskIntoConstraints = false
                new.layer?.backgroundColor = color?.cgColor
                base.addSubview(new)
                NSLayoutConstraint.activate([
                    new.topAnchor.constraint(equalTo: base.topAnchor),
                    new.bottomAnchor.constraint(equalTo: base.bottomAnchor),
                    new.leftAnchor.constraint(equalTo: base.leftAnchor),
                    new.rightAnchor.constraint(equalTo: base.rightAnchor)
                ])
            }
        } else {
            disableView?.removeFromSuperview()
        }
    }
    
}
