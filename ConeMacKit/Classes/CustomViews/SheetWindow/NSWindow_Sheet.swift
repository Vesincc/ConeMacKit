//
//  File.swift
//
//
//  Created by HanQi on 2023/11/13.
//

import Foundation
import Cocoa
 

public enum WindowPresentStyle {
    /// 依次显示
    case sheet
    /// 直接置顶
    case criticalSheet
    /// popup
    case popup
    /// 窗口中间
    case center
    
}


extension NSWindow {
    
    private static var _standardButtonEnableTemp = 1
    var standardButtonEnableTemp: [String : Any]? {
        get {
            objc_getAssociatedObject(self, &NSWindow._standardButtonEnableTemp) as? [String : Any]
        }
        set {
            objc_setAssociatedObject(self, &NSWindow._standardButtonEnableTemp, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}


public extension NSWindow {
     
    func present(_ windowToPresent: NSWindow, isEnableStandardButton: Bool = true, style: WindowPresentStyle, completion: (() -> ())? = nil) {
        switch style {
        case .sheet:
            beginSheet(windowToPresent)
        case .criticalSheet:
            beginCriticalSheet(windowToPresent)
        case .center, .popup:
            addChildWindow(windowToPresent, ordered: .above)
            let sizeOffset = CGSize(width: (frame.width - windowToPresent.frame.width) / 2.0, height: (frame.height - windowToPresent.frame.height) / 2.0)
            windowToPresent.setFrame(CGRect(origin: CGPoint(x: frame.origin.x + sizeOffset.width, y: frame.origin.y + sizeOffset.height), size: windowToPresent.frame.size), display: true)
            windowToPresent.makeKeyAndOrderFront(nil)
        }
        if !isEnableStandardButton {
            var temp: [String : Any] = [:]
            if let button = standardWindowButton(.zoomButton) {
                temp["zoomButton"] = button.isEnabled
                standardWindowButton(.zoomButton)?.isEnabled = false
            }
            if let button = standardWindowButton(.closeButton) {
                temp["closeButton"] = button.isEnabled
                standardWindowButton(.closeButton)?.isEnabled = false
            }
            if let button = standardWindowButton(.miniaturizeButton) {
                temp["miniaturizeButton"] = button.isEnabled
                standardWindowButton(.miniaturizeButton)?.isEnabled = false
            }
            if styleMask.contains(.resizable) {
                temp["styleMask.resizable"] = true
                styleMask.remove(.resizable)
            }
            standardButtonEnableTemp = temp
        }
        (windowToPresent as? SheetWindow)?.style = style
        windowToPresent.preventsApplicationTerminationWhenModal = false
        completion?()
    }
    
    func present(_ viewControllerToPresent: NSViewController, isEnableStandardButton: Bool = true, style: WindowPresentStyle, appearance: NSAppearance? = nil, completion: (() -> ())? = nil) {
        present(SheetWindow(contentViewController: viewControllerToPresent, appearance: appearance), isEnableStandardButton: isEnableStandardButton, style: style, completion: completion)
    }
    
    func dismiss(completion: (() -> ())?) {
        let restoreStandardButton = { [weak self] in
            if let p = self?.sheetParent ?? self?.parent, let temp = p.standardButtonEnableTemp ?? p.standardButtonEnableTemp {
                if let zoomButton = temp["zoomButton"] as? Bool {
                    p.standardWindowButton(.zoomButton)?.isEnabled = zoomButton
                }
                if let closeButton = temp["closeButton"] as? Bool {
                    p.standardWindowButton(.closeButton)?.isEnabled = closeButton
                }
                if let miniaturizeButton = temp["miniaturizeButton"] as? Bool {
                    p.standardWindowButton(.miniaturizeButton)?.isEnabled = miniaturizeButton
                }
                if let resizable = temp["styleMask.resizable"] as? Bool, resizable == true {
                    p.styleMask.insert(.resizable)
                }
                p.standardButtonEnableTemp = nil
            }
        }
        if let sheetWindow = self as? SheetWindow {
            sheetWindow.closeWindow(completion: completion)
        } else if let sheetParent = sheetParent {
            restoreStandardButton()
            sheetParent.endSheet(self)
            completion?()
        } else if let parent = parent {
            restoreStandardButton()
            parent.removeChildWindow(self)
            orderOut(nil)
            completion?()
        } else {
            restoreStandardButton()
            orderOut(nil)
            completion?()
        }
    }
    
    
}
