//
//  File.swift
//  
//
//  Created by HanQi on 2022/11/23.
//

import Foundation

public class Weak<T: AnyObject> {
    public weak var value : T?
    public init (value: T) {
        self.value = value
    }
}
