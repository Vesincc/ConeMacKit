//
//  File.swift
//
//
//  Created by HanQi on 2023/11/13.
//

import Foundation
import Cocoa

public extension NSViewController {
     
    func present(_ viewControllerToPresent: NSViewController, style: WindowPresentStyle, appearance: NSAppearance? = nil, completion: (() -> ())? = nil) {
        view.window?.present(viewControllerToPresent, style: style, appearance: appearance, completion: completion)
    }
    
    func dismiss(completion: (() -> ())?) {
        view.window?.dismiss(completion: completion)
    }
    
}
