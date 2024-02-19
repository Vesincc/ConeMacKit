//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public extension Array {
    
    /// 随机取出数组元素
    /// - Parameter randomCount: 取出个数
    /// - Returns: res
    func random(_ randomCount: Int) -> [Element] {
        var temp: [Element] = self
        var result: [Element] = []
        if isEmpty {
            return result
        }
        let minCount = Swift.min(count, randomCount)
        for _ in 0 ..< minCount {
            result.append(temp.remove(at: Int.random(in: 0 ..< temp.count)))
        }
        return result
    }
    
}

public extension Array where Element: Hashable {
    
    /// 是否有相同元素
    /// - Parameter array: [Element]
    /// - Returns: true 有
    func sameElement(_ array: Self) -> Bool {
        var seen: Set<Element> = []
        seen.formSymmetricDifference(Set(array))
        seen.formSymmetricDifference(Set(self))
        return seen.count != 0
    }
    
     
    /// 移除重复元素
    /// - Returns: res
    @discardableResult mutating func removeDuplicates() -> [Element] {
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        return self
    }
    
}
