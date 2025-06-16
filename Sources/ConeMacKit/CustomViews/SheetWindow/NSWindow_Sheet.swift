//
//  File.swift
//
//
//  Created by HanQi on 2023/11/13.
//

import Foundation
import AppKit
 

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
    public func disableStandardButtonState() {
        var temp: [String : Any] = [:]
        if let button = standardWindowButton(.zoomButton) {
            temp["zoomButton"] = button.isEnabled
            if button.isEnabled {
                standardWindowButton(.zoomButton)?.isEnabled = false
            }
        }
        if let button = standardWindowButton(.closeButton) {
            temp["closeButton"] = button.isEnabled
            if button.isEnabled {
                standardWindowButton(.closeButton)?.isEnabled = false
            }
        }
        if let button = standardWindowButton(.miniaturizeButton) {
            temp["miniaturizeButton"] = button.isEnabled
            if button.isEnabled {
                standardWindowButton(.miniaturizeButton)?.isEnabled = false
            }
        }
        if styleMask.contains(.resizable) {
            temp["styleMask.resizable"] = true
            styleMask.remove(.resizable)
        }
        standardButtonEnableTemp = temp
    }
    public func restoreDisableStandardButtonState() {
        if let temp = standardButtonEnableTemp {
            if let zoomButtonEnable = temp["zoomButton"] as? Bool {
                if zoomButtonEnable {
                    standardWindowButton(.zoomButton)?.isEnabled = zoomButtonEnable
                }
            }
            if let closeButtonEnable = temp["closeButton"] as? Bool {
                if closeButtonEnable {
                    standardWindowButton(.closeButton)?.isEnabled = closeButtonEnable
                }
            }
            if let miniaturizeButtonEnable = temp["miniaturizeButton"] as? Bool {
                if miniaturizeButtonEnable {
                    standardWindowButton(.miniaturizeButton)?.isEnabled = miniaturizeButtonEnable
                }
            }
            if let resizable = temp["styleMask.resizable"] as? Bool, resizable == true {
                styleMask.insert(.resizable)
            }
            standardButtonEnableTemp = nil
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
            disableStandardButtonState()
        }
        (windowToPresent as? SheetWindow)?.style = style
        windowToPresent.preventsApplicationTerminationWhenModal = false
        completion?()
    }
    
    @discardableResult
    func present(_ viewControllerToPresent: NSViewController, isEnableStandardButton: Bool = true, style: WindowPresentStyle, appearance: NSAppearance? = nil, completion: (() -> ())? = nil) -> SheetWindow {
        let window = SheetWindow(contentViewController: viewControllerToPresent, appearance: appearance)
        present(window, isEnableStandardButton: isEnableStandardButton, style: style, completion: completion)
        return window
    }
    
    func dismiss(completion: (() -> ())?) {
        if let sheetWindow = self as? SheetWindow {
            sheetWindow.restoreDisableStandardButtonState()
            sheetWindow.closeWindow(completion: completion)
        } else if let sheetParent = sheetParent {
            sheetParent.restoreDisableStandardButtonState()
            sheetParent.endSheet(self)
            completion?()
        } else if let parent = parent {
            parent.restoreDisableStandardButtonState()
            parent.removeChildWindow(self)
            orderOut(nil)
            completion?()
        } else {
            restoreDisableStandardButtonState()
            orderOut(nil)
            completion?()
        }
    }
    
    
}
