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

public extension NSWindow {
     
    func present(_ windowToPresent: NSWindow, style: WindowPresentStyle, completion: (() -> ())? = nil) {
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
        (windowToPresent as? SheetWindow)?.style = style
        windowToPresent.preventsApplicationTerminationWhenModal = false
        completion?()
    }
    
    func present(_ viewControllerToPresent: NSViewController, style: WindowPresentStyle, appearance: NSAppearance? = nil, completion: (() -> ())? = nil) {
        present(SheetWindow(contentViewController: viewControllerToPresent, appearance: appearance), style: style, completion: completion)
    }
    
    func dismiss(completion: (() -> ())?) {
        if let sheetWindow = self as? SheetWindow {
            sheetWindow.closeWindow(completion: completion)
        } else if let sheetParent = sheetParent {
            sheetParent.endSheet(self)
            completion?()
        } else if let parent = parent {
            parent.removeChildWindow(self)
            orderOut(nil)
            completion?()
        } else {
            orderOut(nil)
            completion?()
        }
    }
    
    
}
