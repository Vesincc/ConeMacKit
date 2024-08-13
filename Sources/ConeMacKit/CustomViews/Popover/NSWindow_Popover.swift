//
//  File.swift
//
//
//  Created by HanQi on 2023/11/17.
//

import Foundation
import AppKit

public enum WindowPopoverDirection {
    case top
    case left
    case right
    case bottom
}

public enum PopoverDirectionAlignment {
    case center
    case leading
    case trailing
}

public enum WindowPopoverStyle {
    case none
    case popup
    case popover
}

public extension NSWindow {
     
    func popover(_ windowToPresent: PopoverWindow, style: WindowPopoverStyle = .none, completion: (() -> ())? = nil) {
        addChildWindow(windowToPresent, ordered: .above)
        if let vc = windowToPresent.contentViewController as? PopoverViewController {
            windowToPresent.setFrame(vc.calculateWindowFrame(), display: true)
        }
        windowToPresent.makeKeyAndOrderFront(nil)
        windowToPresent.style = style
        windowToPresent.preventsApplicationTerminationWhenModal = false
        completion?()
    }
    
    func popover(_ viewControllerToPresent: NSViewController, sourceView: NSView?, style: WindowPopoverStyle = .none, configer: PopoverConfiger, completion: (() -> ())? = nil) {
        let pc = PopoverViewController(contentViewController: viewControllerToPresent, sourceView: sourceView, configer: configer)
        let pop = PopoverWindow(contentViewController: pc, appearance: configer.appearance)
        popover(pop, style: style, completion: completion)
    }
    
    func dismissPopover(completion: (() -> ())?) {
        if let sheetWindow = self as? PopoverWindow {
            sheetWindow.closeWindow(completion: completion)
        } else {
            orderOut(nil)
            completion?()
        }
    }
    
}
