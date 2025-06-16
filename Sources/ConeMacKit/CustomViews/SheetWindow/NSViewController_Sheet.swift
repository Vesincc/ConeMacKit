//
//  File.swift
//
//
//  Created by HanQi on 2023/11/13.
//

import Foundation
import AppKit

public extension NSViewController {
     
    @discardableResult
    func present(_ viewControllerToPresent: NSViewController, isEnableStandardButton: Bool = true, style: WindowPresentStyle, appearance: NSAppearance? = nil, completion: (() -> ())? = nil) -> SheetWindow? {
        view.window?.present(viewControllerToPresent, isEnableStandardButton: isEnableStandardButton, style: style, appearance: appearance, completion: completion)
    }
    
    func dismiss(completion: (() -> ())?) {
        view.window?.dismiss(completion: completion)
    }
    
}
