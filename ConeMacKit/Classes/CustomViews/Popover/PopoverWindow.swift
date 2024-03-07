//
//  File.swift
//
//
//  Created by HanQi on 2023/11/21.
//

import Foundation
import Cocoa

public class PopoverWindow: NSWindow {
    
    var style: WindowPopoverStyle = .none {
        didSet {
            configerStyle()
        }
    }
    
    var localMonitore: Any?
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        appearance = NSAppearance(named: .aqua)
        backgroundColor = .clear
    }
    
    public convenience init(contentViewController: PopoverViewController) {
        self.init(contentRect: .zero, styleMask: [.closable, .borderless], backing: .buffered, defer: true)
        self.contentViewController = contentViewController
        
    }
    
    public override var canBecomeKey: Bool {
        true
    }
    
    
    deinit {
        if let localMonitore = localMonitore {
            NSEvent.removeMonitor(localMonitore)
        }
    }
    
    func addLocalMonirorIgnoresParentMouseEvents() {
        localMonitore = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
            guard let self = self else {
                return event
            }
            if event.window != self {
                if let vc = contentViewController as? PopoverViewController, vc.configer.autoHidden {
                    self.dismissPopover(completion: nil)
                }
                return nil
            }
            return event
        }
    }
    
    func configerStyle() {
        switch style {
        case .none:
            break
        case .popup:
            addLocalMonirorIgnoresParentMouseEvents()
            popupOpenAnimation()
        case .popover:
            addLocalMonirorIgnoresParentMouseEvents()
            popoverOpenAnimation()
        }
    }
    
    func closeWindow(completion: (() -> ())?) {
        switch style {
        case .none:
            parent?.removeChildWindow(self)
            orderOut(nil)
            completion?()
        case .popup:
            popupCloseAnimation { [weak self] in
                guard let self = self else {
                    return
                }
                self.parent?.removeChildWindow(self)
                self.orderOut(nil)
                completion?()
            }
        case .popover:
            break
        }
        
    }
    
}

extension PopoverWindow {
    
    func popupOpenAnimation(completion: (() -> ())? = nil) {
        guard let contentView = contentView else {
            return
        }
        DispatchQueue.main.async {
            contentView.layer?.position = CGPoint(x: contentView.bounds.width / 2.0, y: contentView.bounds.height / 2.0)
            contentView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            contentView.alphaValue = 0.7
            contentView.layer?.setAffineTransform(.init(scaleX: 0.9, y: 0.9))
             
            DispatchQueue.main.async {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    context.duration = 0.2
                    contentView.animator().alphaValue = 1
                    contentView.animator().layer?.setAffineTransform(.identity)
                } completionHandler: {
                    completion?()
                }
            }
        }
    }
    
    func popupCloseAnimation(completion: (() -> ())? = nil) {
        guard let contentView = contentView else {
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = 0.2
            contentView.animator().alphaValue = 0
            contentView.animator().layer?.setAffineTransform(.init(scaleX: 0.9, y: 0.9))
        } completionHandler: {
            completion?()
        }
    }
    
}

extension PopoverWindow {
    
    func popoverOpenAnimation(completion: (() -> ())? = nil) {
        guard let contentView = contentView else {
            return
        }
        guard let vc = contentViewController as? PopoverViewController else {
            return
        }
        let _ = vc.configer.indicatorOffset
        switch vc.direction {
        case .top:
            break
        case .left:
            break
        case .right:
            break
        case .bottom:
            break
        }
        DispatchQueue.main.async {
            contentView.layer?.position = CGPoint(x: contentView.bounds.width / 2.0, y: contentView.bounds.height / 2.0)
            contentView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            contentView.alphaValue = 0.7
            contentView.layer?.setAffineTransform(.init(scaleX: 0.8, y: 0.8))
             
            DispatchQueue.main.async {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    context.duration = 0.2
                    contentView.animator().alphaValue = 1
                    contentView.animator().layer?.setAffineTransform(.identity)
                } completionHandler: {
                    completion?()
                }
            }
        }
    }
    
    func popoverCloseAnimation(completion: (() -> ())? = nil) {
        guard let contentView = contentView else {
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = 0.2
            contentView.animator().alphaValue = 0
            contentView.animator().layer?.setAffineTransform(.init(scaleX: 0.9, y: 0.9))
        } completionHandler: {
            completion?()
        }
    }
    
}
