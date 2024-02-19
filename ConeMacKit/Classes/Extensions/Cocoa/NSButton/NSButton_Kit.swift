//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/10.
//

import Foundation
import Cocoa

public extension NSButton {
    
    func addTarget(_ target: Any?, action: Selector) {
        self.target = target as AnyObject?
        self.action = action
    }
    
}
