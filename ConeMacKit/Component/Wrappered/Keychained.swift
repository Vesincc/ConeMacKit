//
//  File.swift
//  
//
//  Created by HanQi on 2022/11/23.
//

import Foundation

@propertyWrapper
public struct Keychained<Value: Codable> {
    private let key: String
    
    // 存储默认值
    private var objectedValue: Value
    
    public var wrappedValue: Value {
        get {
            guard let data = KeyChainManager.value(forKey: key) else {
                return objectedValue
            }
            let decoder = JSONDecoder.init()
            let object = try? decoder.decode([Value].self, from: data)
            return object?.first ?? objectedValue
        }
        set {
            let encoder = JSONEncoder.init()
            let data = try? encoder.encode([newValue])
            
            if data == nil {
                KeyChainManager.removeValue(forKey: key)
            } else {
                KeyChainManager.setValue(data, forKey: key)
            }
        }
    }
    
    public init(key: String, defaultValue: Value) {
        self.key = key
        self.objectedValue = defaultValue
    }
}


public class KeyChainManager {
    
    /// 存储
    /// - Parameters:
    ///   - value: value
    ///   - key: key
    /// - Returns: 成功 失败
    @discardableResult
    fileprivate class func setValue(_ value: Data?, forKey key: String) -> Bool {
        if updateValue(value, forKey: key) {
            return true
        }
        
        var query = createqueryDictionary(with: key)
        SecItemDelete(query as CFDictionary)
        
        query[kSecValueData as String] = value
        // 进行存储数据
        let saveState = SecItemAdd(query as CFDictionary, nil)
        if saveState == noErr  {
            return true
        }
        return false
    }
      
    /// 获取数据
    /// - Parameter key: key
    /// - Returns: any
    fileprivate class func value(forKey key: String) -> Data? {
        var query = createqueryDictionary(with: key)
        
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var queryResult: AnyObject?
        
        let readStatus = withUnsafeMutablePointer(to: &queryResult) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))}
        if readStatus == errSecSuccess {
            return queryResult as? Data
        }
        return nil
    }
    
    /// 删除
    /// - Parameter key: key
    public class func removeValue(forKey key: String) {
        let query = createqueryDictionary(with: key)
        SecItemDelete(query as CFDictionary)
    }
    
    /// 删除全部
    public class func removeAll() {
        var query: [String : Any] = [
            kSecReturnAttributes as String : true,
            kSecMatchLimit as String : kSecMatchLimitAll
        ]
        
        let secItemClasses = [
            kSecClassGenericPassword as String,
            kSecClassInternetPassword as String,
            kSecClassCertificate as String,
            kSecClassKey as String,
            kSecClassIdentity as String
        ]
        
        secItemClasses.forEach { (secItemClass) in
            query[kSecClass as String] = secItemClass
            var queryResult: AnyObject?
            SecItemCopyMatching(query as CFDictionary, &queryResult)
            
            let spec = [kSecClass as String : secItemClass]
            SecItemDelete(spec as CFDictionary)
        }
    }
}

extension KeyChainManager {
    
    private class func createqueryDictionary(with identifier: String) -> [String : Any] {
        // 创建一个条件字典
        var keychainquery: [String : Any] = [:]
        // 设置条件存储的类型
        keychainquery[kSecClass as String] = kSecClassGenericPassword
        // 设置存储数据的标记
        keychainquery[kSecAttrService as String] = identifier
        keychainquery[kSecAttrAccount as String] = identifier
        // 设置数据访问属性
        keychainquery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        
        // 返回创建条件字典
        return keychainquery
    }
    
    @discardableResult
    private static func updateValue(_ value: Data?, forKey key: String) -> Bool {
        // 获取更新的条件
        let query = createqueryDictionary(with: key)
        // 创建数据存储字典
        var updataDictionary: [String : Any] = [:]
        // 设置数据
        updataDictionary[kSecValueData as String] = value
        
        // 更新数据
        let updataStatus = SecItemUpdate(query as CFDictionary, updataDictionary as CFDictionary)
        if updataStatus == noErr {
            return true
        }
        return false
    }
    
}
