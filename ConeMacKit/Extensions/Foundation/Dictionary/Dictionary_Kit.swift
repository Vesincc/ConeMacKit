//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public extension Dictionary {
    /// 字典相加
    /// - Note
    /// 如 lhs 和 rhs 相同的key lhs 中的 value 会被 替换
    static func + (lhs: [Key: Value], rhs: [Key: Value]?) -> [Key: Value] {
        guard let rhs = rhs else {
            return lhs
        }
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
}
