//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public extension NSObject {
    
    /// 方法交换
    /// - Parameters:
    ///   - aClass: Class
    ///   - originalSelector: originalSelector
    ///   - swizzledSelector: swizzledSelector
    class func swizzleMethod(for aClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        
        let didAddMethod: Bool = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        if didAddMethod {
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    
    
    
    
}
