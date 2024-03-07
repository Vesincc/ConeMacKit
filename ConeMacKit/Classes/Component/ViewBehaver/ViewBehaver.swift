//
//  File.swift
//
//
//  Created by HanQi on 2023/12/20.
//

import Foundation
import Cocoa

 
extension NSView {
    
    fileprivate static var _updateTrackingAreaAssociated = 0
    var updateTrackingAreaAssociated: [(() -> ())?] {
        get {
            objc_getAssociatedObject(self, &NSView._updateTrackingAreaAssociated) as? [(() -> ())?] ?? []
        }
        set {
            objc_setAssociatedObject(self, &NSView._updateTrackingAreaAssociated, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate static var _mouseEnteredAssociated = 0
    var mouseEnteredAssociated: [((NSEvent) -> ())?] {
        get {
            objc_getAssociatedObject(self, &NSView._mouseEnteredAssociated) as? [((NSEvent) -> ())?] ?? []
        }
        set {
            objc_setAssociatedObject(self, &NSView._mouseEnteredAssociated, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate static var _mouseExitedAssociated = 0
    var mouseExitedAssociated: [((NSEvent) -> ())?] {
        get {
            objc_getAssociatedObject(self, &NSView._mouseExitedAssociated) as? [((NSEvent) -> ())?] ?? []
        }
        set {
            objc_setAssociatedObject(self, &NSView._mouseExitedAssociated, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate static var _hitTestAssociated = 0
    var hitTestAssociated: ((NSPoint) -> NSView?)? {
        get {
            objc_getAssociatedObject(self, &NSView._hitTestAssociated) as? (NSPoint) -> NSView?
        }
        set {
            objc_setAssociatedObject(self, &NSView._hitTestAssociated, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    fileprivate static var _resetCursorRectsAssociated = 0
    var resetCursorRectsAssociated: [(() -> ())?] {
        get {
            objc_getAssociatedObject(self, &NSView._resetCursorRectsAssociated) as? [(() -> ())?] ?? []
        }
        set {
            objc_setAssociatedObject(self, &NSView._resetCursorRectsAssociated, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}



public struct ViewBehaverWrapper<Base: NSView> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
        var temp: Bool?
        if let s = base.superview as? NSStackView {
            temp = s.detachesHiddenViews
            if temp == true {
                s.detachesHiddenViews = false
            }
        }
        createNewClassIfNeed()
        if let s = base.superview as? NSStackView, let temp = temp, s.detachesHiddenViews != temp {
            s.detachesHiddenViews = temp
        }
    }
     
    
    private func createNewClassIfNeed() {
        let classNamePrefix = "ViewBehaverWrapper.Class."
        guard let originalClass: AnyClass = object_getClass(base) else {
            return
        }
        let className = NSStringFromClass(originalClass)
        if className.hasPrefix(classNamePrefix) {
            return
        }
        let newClassName = "\(classNamePrefix)\(base.self)"
        if let newClass = NSClassFromString(newClassName) {
            object_setClass(base, newClass)
        } else {
            guard let newClass: AnyClass = objc_allocateClassPair(originalClass, newClassName, 0) else {
                return
            }
            let sel = NSSelectorFromString("class")
            if let originalMethod = class_getInstanceMethod(originalClass, sel) {
                let type = method_getTypeEncoding(originalMethod)
                let block: @convention(block) (NSObject) -> AnyClass? = { o in
                    return class_getSuperclass(object_getClass(o))
                }
                let imp = imp_implementationWithBlock(block)
                class_addMethod(newClass, sel, imp, type)
            }
             
            hockResetCursorRects(to: newClass, originalClass: originalClass)
            hockUpdateTrackingAreas(to: newClass, originalClass: originalClass)
            hockMouseEntered(to: newClass, originalClass: originalClass)
            hockMouseExited(to: newClass, originalClass: originalClass)
            hockHitTest(to: newClass, originalClass: originalClass)
             
            objc_registerClassPair(newClass)
            object_setClass(base, newClass)
              
        }
    }
     
    
    private func hockUpdateTrackingAreas(to newClass: AnyClass, originalClass: AnyClass) {
        let sel = #selector(Base.updateTrackingAreas)
        guard let originalMethod = class_getInstanceMethod(originalClass, sel) else {
            return
        }
        let type = method_getTypeEncoding(originalMethod)
        let block: @convention(block) (NSObject) -> Void = { o in
            guard let v = o as? NSView else {
                return
            }
            let op = #selector(Base.updateTrackingAreas)
            if let method = class_getInstanceMethod(originalClass, op) {
                let imp = method_getImplementation(method)
                typealias fun = @convention(c) (AnyObject, Selector) -> Void
                let fn = unsafeBitCast(imp, to: fun.self)
                fn(v, op)
            }
            v.updateTrackingAreaAssociated.forEach({ $0?() })
        }
        let imp = imp_implementationWithBlock(block)
        class_addMethod(newClass, sel, imp, type)
    }
    
    private func hockMouseEntered(to newClass: AnyClass, originalClass: AnyClass) {
        let sel = #selector(Base.mouseEntered(with:))
        guard let originalMethod = class_getInstanceMethod(originalClass, sel) else {
            return
        }
        let type = method_getTypeEncoding(originalMethod)
        let block: @convention(block) (NSObject, NSEvent) -> Void = { o, e in
            guard let v = o as? NSView else {
                return
            }
            let op = #selector(Base.mouseEntered(with:))
            if let method = class_getInstanceMethod(originalClass, op) {
                let imp = method_getImplementation(method)
                typealias fun = @convention(c) (AnyObject, Selector, NSEvent) -> Void
                let fn = unsafeBitCast(imp, to: fun.self)
                fn(v, op, e)
            }
            v.mouseEnteredAssociated.forEach({ $0?(e) })
        }
        let imp = imp_implementationWithBlock(block)
        class_addMethod(newClass, sel, imp, type)
    }
    
    
    private func hockMouseExited(to newClass: AnyClass, originalClass: AnyClass) {
        let sel = #selector(Base.mouseExited(with:))
        guard let originalMethod = class_getInstanceMethod(originalClass, sel) else {
            return
        }
        let type = method_getTypeEncoding(originalMethod)
        let block: @convention(block) (NSObject, NSEvent) -> Void = { o, e in
            guard let v = o as? NSView else {
                return
            }
            let op = #selector(Base.mouseExited(with:))
            if let method = class_getInstanceMethod(originalClass, op) {
                let imp = method_getImplementation(method)
                typealias fun = @convention(c) (AnyObject, Selector, NSEvent) -> Void
                let fn = unsafeBitCast(imp, to: fun.self)
                fn(v, op, e)
            }
            v.mouseExitedAssociated.forEach({ $0?(e) })
        }
        let imp = imp_implementationWithBlock(block)
        class_addMethod(newClass, sel, imp, type)
    }
    
    private func hockHitTest(to newClass: AnyClass, originalClass: AnyClass) {
        let sel = #selector(Base.hitTest(_:))
        guard let originalMethod = class_getInstanceMethod(originalClass, sel) else {
            return
        }
        let type = method_getTypeEncoding(originalMethod)
        let block: @convention(block) (NSObject, NSPoint) -> NSView? = { o, p in
            guard let v = o as? NSView else {
                return nil
            }
            let op = #selector(Base.hitTest(_:))
            if let hitTest = v.hitTestAssociated {
                return hitTest(p)
            }
            if let method = class_getInstanceMethod(originalClass, op) {
                let imp = method_getImplementation(method)
                typealias fun = @convention(c) (AnyObject, Selector, NSPoint) -> NSView?
                let fn = unsafeBitCast(imp, to: fun.self)
                return fn(v, op, p)
            }
            return nil
        }
        let imp = imp_implementationWithBlock(block)
        class_addMethod(newClass, sel, imp, type)
    }
    
    func hockResetCursorRects(to newClass: AnyClass, originalClass: AnyClass) {
        let sel = #selector(Base.resetCursorRects)
        guard let originalMethod = class_getInstanceMethod(originalClass, sel) else {
            return
        }
        let type = method_getTypeEncoding(originalMethod)
        let block: @convention(block) (NSObject) -> Void = { o in
            guard let v = o as? NSView else {
                return
            }
            let op = #selector(Base.resetCursorRects)
            if let method = class_getInstanceMethod(originalClass, op) {
                let imp = method_getImplementation(method)
                typealias fun = @convention(c) (AnyObject, Selector) -> Void
                let fn = unsafeBitCast(imp, to: fun.self)
                fn(v, op)
            }
            v.resetCursorRectsAssociated.forEach({ $0?() })
        }
        let imp = imp_implementationWithBlock(block)
        class_addMethod(newClass, sel, imp, type)
    }
    
}


public protocol ViewBehaverCompatible: NSView { }
 

extension ViewBehaverCompatible {
    public var viewBehaver: ViewBehaverWrapper<Self> {
        get { return ViewBehaverWrapper(self) }
        set { }
    }
}
 


extension NSView: ViewBehaverCompatible {}
