//
//  File.swift
//
//
//  Created by HanQi on 2023/11/13.
//

import Foundation
import AppKit

public protocol SheetWindowCloseProtocol: NSViewController {
    
    var closeEnable: Bool { get }
    var closeOffset: CGPoint { get }
    
    func closeAction(sender: NSButton)
    
}

public extension SheetWindowCloseProtocol {
    
    var closeEnable: Bool {
        true
    }
    var closeOffset: CGPoint {
        .zero
    }
    func closeAction(sender: NSButton) {
        dismiss(completion: nil)
    }
    
}
 
public class SheetWindow: NSWindow {
    
    public var windowButtonGroup: WindowButtonGroupBar?
    
    var style: WindowPresentStyle? {
        didSet {
           configerStyle()
        }
    }
    
    private var localMonitore: Any?
    
    public override func standardWindowButton(_ b: NSWindow.ButtonType) -> NSButton? {
        windowButtonGroup?.button(for: b) ?? super.standardWindowButton(b)
    }
     
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    }
    
    public convenience init(contentViewController: NSViewController) {
        self.init(contentViewController: contentViewController, appearance: nil)
    }
     
    public convenience init(contentViewController: NSViewController, appearance: NSAppearance? = nil) {
        self.init(contentRect: .zero, styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
        self.contentViewController = contentViewController
        self.isReleasedWhenClosed = true
        self.title = contentViewController.title ?? ""
        self.appearance = appearance ?? NSApplication.shared.mainWindow?.appearance
        
        
        var closeEnable = true
        var offset: CGPoint = .zero
        if let close = contentViewController as? SheetWindowCloseProtocol {
            closeEnable = close.closeEnable
            offset = close.closeOffset
        }
         
        if closeEnable {
            contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
            let group = WindowButtonGroupBar(types: [.closeButton])
            group.appearance = appearance ?? self.appearance
            group.buttons.forEach({ $0?.target = self })
            group.translatesAutoresizingMaskIntoConstraints = false
            group.button(for: .closeButton)?.addTarget(self, action: #selector(closeAction))
            
            contentViewController.view.addSubview(group)
            NSLayoutConstraint.activate([
                group.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor, constant: 8 + offset.x),
                group.topAnchor.constraint(equalTo: contentViewController.view.topAnchor, constant: 8 + offset.y)
            ])
            self.windowButtonGroup = group
        }
    }
       
    public override var canBecomeKey: Bool {
        true
    }
    
    public override var canBecomeMain: Bool {
        false
    }
    
    func addWindowNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(notification:)), name: NSWindow.willCloseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowResize(notification:)), name: NSWindow.didResizeNotification, object: nil)
    }
    
    func addLocalMonirorIgnoresParentMouseEvents() {
        localMonitore = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
            guard let self = self else {
                return event
            }
            if event.window != self {
                return nil
            }
            return event
        }
    }
    
    @objc func windowWillClose(notification: Notification) {
        if let window = notification.object as? NSWindow, window == parent {
            closeAction()
        }
    }
    
    @objc func windowResize(notification: Notification) {
        if let notificationWindow = notification.object as? NSWindow, (notificationWindow == parent || notificationWindow == self) {
            guard let window = parent else {
                return
            }
            let sizeOffset = CGSize(width: (window.frame.width - frame.width) / 2.0, height: (window.frame.height - frame.height) / 2.0)
            setFrame(CGRect(origin: CGPoint(x: window.frame.origin.x + sizeOffset.width, y: window.frame.origin.y + sizeOffset.height), size: frame.size), display: true)
        }
    }
    
    func configerStyle() {
        NotificationCenter.default.removeObserver(self)
        guard let style = style else {
            return
        }
        switch style {
        case .sheet, .criticalSheet:
            break
        case .center:
            addWindowNotification()
            addLocalMonirorIgnoresParentMouseEvents()
        case .popup:
            addWindowNotification()
            addLocalMonirorIgnoresParentMouseEvents()
            popupOpenAnimation()
        }
    }
    
    @objc func closeAction() {
        if let close = contentViewController as? SheetWindowCloseProtocol, close.closeEnable, let closeButton = windowButtonGroup?.button(for: .closeButton) {
            close.closeAction(sender: closeButton)
        } else {
            closeWindow(completion: nil)
        }
    }
    
    func closeWindow(completion: (() -> ())?) {
        (sheetParent ?? parent)?.restoreDisableStandardButtonState()
        if let style = style {
            switch style {
            case .sheet, .criticalSheet:
                sheetParent?.endSheet(self)
                completion?()
            case .center:
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
            }
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let localMonitore = localMonitore {
            NSEvent.removeMonitor(localMonitore)
        }
    }
     
    
}

 

extension SheetWindow {
    
    func popupOpenAnimation(completion: (() -> ())? = nil) {
        guard let contentView = contentView else {
            return
        }
        
        contentView.wantsLayer = true
        DispatchQueue.main.async {
            contentView.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
         
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.7
        fade.toValue = 1
        
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1))
        scale.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        
        let animation = CAAnimationGroup()
        animation.animations = [fade, scale]
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        contentView.layer?.add(animation, forKey: "popupOpenAnimation")
        CATransaction.commit()
    }
    
    func popupCloseAnimation(completion: (() -> ())? = nil) {
        guard let contentView = contentView else {
            return
        }
        
        contentView.wantsLayer = true // 确保视图有layer支持
        
        DispatchQueue.main.async {
            contentView.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
         
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = contentView.layer?.opacity
        fadeOut.toValue = 0
         
        let scaleDown = CABasicAnimation(keyPath: "transform")
        scaleDown.fromValue = contentView.layer?.transform
        scaleDown.toValue = CATransform3DMakeScale(0.9, 0.9, 1)
         
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [fadeOut, scaleDown]
        animationGroup.duration = 0.2
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animationGroup.fillMode = .backwards
         
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
         
        contentView.layer?.add(animationGroup, forKey: "popupCloseAnimation")
        
        CATransaction.commit()
        
    }
    
}
