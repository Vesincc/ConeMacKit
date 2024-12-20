//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation
import CommonCrypto

public extension String {
    
    subscript(offset: Int) -> Character {
        get {
            return self[index(startIndex, offsetBy: offset)]
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: offset)..<index(startIndex, offsetBy: offset + 1), with: [newValue])
        }
    }
    
    subscript(range: CountableRange<Int>) -> String {
        get {
            return String(self[index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound), with: newValue)
        }
    }
    
    subscript(location: Int, length: Int) -> String {
        get {
            return String(self[index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length), with: newValue)
        }
    }
    
}

public extension String {
    
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    /// 创建随机字符串
    /// - Parameter length: 长度
    /// - Returns: 字符串
    static func random(with length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            ranStr.append(characters[index])
        }
        return ranStr
    }
    
    static func randomNumberString(with length: Int) -> String {
        let characters = "0123456789"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            if ranStr.isEmpty {
                if characters[index] != "0" {
                    ranStr.append(characters[index])
                }
            } else {
                ranStr.append(characters[index])
            }
        }
        if ranStr.isEmpty {
            return randomNumberString(with: length)
        }
        return ranStr
    }
    
    /// range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    /// 验证正则表达式
    /// - Parameter regular: 规则
    /// - Returns: 结果 true 正确
    func verification(with regular: String) -> Bool {
        let regularExpression = try? NSRegularExpression(pattern: regular, options: .caseInsensitive)
        let matchs = regularExpression?.matches(in: self, options: .reportProgress, range: NSRange(location: 0, length: count))
        if let count = matchs?.count, count != 0 {
            return true
        }
        return false
    }
     
    func regular(regex: String) -> [NSTextCheckingResult] {
        do {
            let expression = try NSRegularExpression(pattern: regex, options: [])
            return expression.matches(in: self, options: [], range: .init(location: 0, length: count))
        } catch {
            return []
        }
    }
}
  
public extension Array where Element == String {
    
    func merge(with str: String) -> String {
        var res = ""
        forEach { s in
            if !s.isEmpty {
                if res.isEmpty {
                    res = s
                } else {
                    res.append(contentsOf: "\(str)\(s)")
                }
            }
        }
        return res
    }
    
    var firstNotEmpty: String? {
        first(where: { !$0.isEmpty })
    }
    
}
