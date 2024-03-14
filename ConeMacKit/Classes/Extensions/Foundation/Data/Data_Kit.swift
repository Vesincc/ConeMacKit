//
//  Data_Kit.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import Foundation

public extension Data {
     
    /// 异或加密
    /// - Parameter key: key
    /// - Returns: data
    func xor(key: String) -> Data {
        let keyStr = key.data(using: .utf8)!
        var data = self
        let keySize = keyStr.count
        let dataSize = data.count
        for i in 0 ..< dataSize {
            data[i] ^= keyStr[i % keySize]
        }
        return data
    }
    
}
