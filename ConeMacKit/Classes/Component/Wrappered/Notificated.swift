//
//  File.swift
//  
//
//  Created by HanQi on 2022/11/23.
//

import Foundation

@propertyWrapper
public struct Notificated<Value> {
    
    public var wrappedValue: Value {
        didSet {
            NotificationCenter.default.post(name: projectedValue, object: wrappedValue)
        }
    }
    
    public let projectedValue: Notification.Name
    
    public init(wrappedValue: Value, name: Notification.Name, trigger: Bool = true) {
        self.projectedValue = name
        self.wrappedValue = wrappedValue
        
        trigger ? NotificationCenter.default.post(name: name, object: wrappedValue) : ()
    }
}
