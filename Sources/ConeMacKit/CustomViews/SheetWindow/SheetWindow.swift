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
    
    var style: WindowPresentStyle? {
        didSet {
           configerStyle()
        }
    }
    
    private var localMonitore: Any?
    
    private lazy var closeView: NSView = {
        let view = NSView(frame: CGRect(x: 0, y: 0, width: 14, height: 16))
        let bg = NSView(frame: CGRect(x: 1, y: 2, width: 12, height: 12))
        bg.wantsLayer = true
        
        bg.layer?.backgroundColor = NSColor(rgb: 0x000000, alpha: 0.3).cgColor
        bg.layer?.cornerRadius = 6
        view.addSubview(bg)
        
        closeButton?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 14, height: 16))
        view.addSubview(closeButton!)
        view.translatesAutoresizingMaskIntoConstraints = false
        view
            .viewBehaver
            .mouseTracker
            .subscribeMouseTrackEvent({ [weak self] event in
                switch event {
                case .entered:
                    self?.closeButton?.isHighlighted = true
                case .exited:
                    self?.closeButton?.isHighlighted = false
                    self?.closeButton?.alphaValue = 1
                }
            })
        return view
    }()
    
    public lazy var closeButton: NSButton? = {
        let button = NSWindow.standardWindowButton(.closeButton, for: .closable)
        button?.addTarget(self, action: #selector(closeAction))
        if #available(macOS 10.14, *) {
            button?.appearance = NSAppearance(named: .darkAqua)
        } else {
            button?.appearance = NSAppearance(named: .vibrantDark)
        }
        return button
    }()
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        appearance = NSAppearance(named: .aqua)
        backgroundColor = .clear
    }
     
    public convenience init(contentViewController: NSViewController, appearance: NSAppearance? = nil) {
        self.init(contentRect: .zero, styleMask: [.closable, .borderless], backing: .buffered, defer: true)
        self.contentViewController = contentViewController
        self.appearance = appearance ?? NSApplication.shared.mainWindow?.appearance
        var closeEnable = true
        var offset: CGPoint = .zero
        if let close = contentViewController as? SheetWindowCloseProtocol {
            closeEnable = close.closeEnable
            offset = close.closeOffset
        }
         
        if closeEnable {
            contentViewController.view.addSubview(closeView)
            NSLayoutConstraint.activate([
                closeView.topAnchor.constraint(equalTo: contentViewController.view.topAnchor, constant: 8 + offset.x),
                closeView.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor, constant: 8 + offset.y),
                closeView.widthAnchor.constraint(equalToConstant: 14),
                closeView.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
        
        
    }
       
    public override var canBecomeKey: Bool {
        true
    }
    
    public override func becomeKey() {
        super.becomeKey()
        closeButton?.alphaValue = 1
    }
    
    public override func resignKey() {
        super.resignKey()
        closeButton?.alphaValue = 1
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
        if let close = contentViewController as? SheetWindowCloseProtocol, close.closeEnable {
            close.closeAction(sender: closeButton ?? NSButton())
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
