//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/30.
//

import Foundation
import AppKit

public extension NSViewController {
     
    func popover(_ viewControllerToPresent: NSViewController, sourceView: NSView?, style: WindowPopoverStyle = .none, configer: PopoverConfiger, completion: (() -> ())? = nil) {
        view.window?.popover(viewControllerToPresent, sourceView: sourceView, style: style, configer: configer, completion: completion)
    }
    
    func dismissPopover(completion: (() -> ())?) {
        view.window?.dismissPopover(completion: completion)
    }
    
}
