//
//  File.swift
//  
//
//  Created by HanQi on 2022/11/23.
//

import Foundation

@propertyWrapper
public struct UserDefaulted<Value> {
    
    private lazy var defaults: UserDefaults = {
        if let suiteName = suiteName {
            return UserDefaults.init(suiteName: suiteName) ?? UserDefaults.standard
        } else {
            return UserDefaults.standard
        }
    }()
    
    private var suiteName: String? = nil
    
    private let key: String
    
    public var wrappedValue: Value {
        mutating get {
            if defaults.value(forKey: key) == nil {
                return objectedValue
            }
            return defaults.value(forKey: key) as? Value ?? objectedValue
        }
        set {
            defaults.setValue(newValue, forKey: key)
            defaults.synchronize()
        }
    }
    
    // 存储默认值
    private var objectedValue: Value
    
    public init(key: String, defaultValue: Value,  suiteName: String? = nil) {
        self.key = key
        self.objectedValue = defaultValue
        self.suiteName = suiteName
    }
}

@propertyWrapper
public struct UserDefaultCodabled<Value: Codable> {
    
    private lazy var defaults: UserDefaults = {
        if let suiteName = suiteName {
            return UserDefaults.init(suiteName: suiteName) ?? UserDefaults.standard
        } else {
            return UserDefaults.standard
        }
    }()
    
    private var suiteName: String? = nil
    
    private let key: String
    
    public var wrappedValue: Value {
        mutating get {
            guard let data = defaults.value(forKey: key) as? Data else {
                return objectedValue
            }
            let decoder = JSONDecoder.init()
            let object = try? decoder.decode([Value].self, from: data)
            return object?.first ?? objectedValue
        }
        set {
            let encoder = JSONEncoder.init()
            let data = try? encoder.encode([newValue])
            
            defaults.setValue(data, forKey: key)
            defaults.synchronize()
        }
    }
    
    // 存储默认值
    private var objectedValue: Value
    
    public init(key: String, defaultValue: Value,  suiteName: String? = nil) {
        self.key = key
        self.objectedValue = defaultValue
        self.suiteName = suiteName
    }
}
