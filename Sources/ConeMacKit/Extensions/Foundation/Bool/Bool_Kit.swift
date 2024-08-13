//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public extension Bool {
    
    /// int 值 0 1
    var int: Int {
        return self ? 1 : 0
    }

    /// string 值 true false
    var string: String {
        return self ? "true" : "false"
    }
    
}
