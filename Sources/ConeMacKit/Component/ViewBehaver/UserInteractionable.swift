//
//  File.swift
//  
//
//  Created by HanQi on 2023/12/22.
//

import Foundation
import AppKit

public protocol UserInteractionable {
    var isUserInteractionEnabled: Bool { get set }
}

fileprivate extension NSView {
    
    static var _isUserInteractionEnabled = 0
    var isUserInteractionEnabled: Bool {
        get {
            objc_getAssociatedObject(self, &NSView._isUserInteractionEnabled) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &NSView._isUserInteractionEnabled, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    static var _trackingAreasTemp = 0
    var trackingAreasTemp: [NSTrackingArea] {
        get {
            objc_getAssociatedObject(self, &NSView._trackingAreasTemp) as? [NSTrackingArea] ?? []
        }
        set {
            objc_setAssociatedObject(self, &NSView._trackingAreasTemp, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var _updateTrackingAreaAssociatedTemp = 0
    var updateTrackingAreaAssociatedTemp: [(() -> ())?] {
        get {
            objc_getAssociatedObject(self, &NSView._updateTrackingAreaAssociatedTemp) as? [(() -> ())?] ?? []
        }
        set {
            objc_setAssociatedObject(self, &NSView._updateTrackingAreaAssociatedTemp, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension ViewBehaverWrapper: UserInteractionable where Base: NSView {
    public var isUserInteractionEnabled: Bool {
        get {
            base.isUserInteractionEnabled
        }
        set {
            base.isUserInteractionEnabled = newValue
            if newValue {
                base.hitTestAssociated = nil
                base.trackingAreasTemp.forEach { t in
                    base.addTrackingArea(t)
                }
                base.updateTrackingAreaAssociated = base.updateTrackingAreaAssociatedTemp
            } else {
                base.updateTrackingAreaAssociatedTemp = base.updateTrackingAreaAssociated
                base.trackingAreasTemp = base.trackingAreas
                
                base.hitTestAssociated = { p in
                    return nil
                }
                base.updateTrackingAreaAssociated.removeAll()
                base.trackingAreas.forEach { t in
                    base.removeTrackingArea(t)
                }
            }
        }
    }
    
}
