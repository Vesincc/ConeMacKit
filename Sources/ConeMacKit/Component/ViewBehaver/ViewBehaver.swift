//
//  File.swift
//
//
//  Created by HanQi on 2023/12/20.
//

import Foundation
import AppKit
 
public struct ViewBehaverWrapper<Base: NSView> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ViewBehaverCompatible: NSView { }
 
public extension ViewBehaverCompatible {
    var viewBehaver: ViewBehaverWrapper<Self> {
        get { return ViewBehaverWrapper(self) }
        set { }
    }
}

extension NSView: ViewBehaverCompatible {}
 
