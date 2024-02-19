//
//  File.swift
//  
//
//  Created by HanQi on 2022/11/23.
//

import Foundation

@propertyWrapper
public class Blocked<Value> {
     
    public var wrappedValue: Value {
        didSet {
            projectedValue?(wrappedValue)
        }
    }
    
    public var projectedValue: ((Value) -> Void)? {
        didSet {
            projectedValue?(wrappedValue)
        }
    }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        projectedValue?(wrappedValue)
    }
}
