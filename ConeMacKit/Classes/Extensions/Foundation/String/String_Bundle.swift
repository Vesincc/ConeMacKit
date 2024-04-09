//
//  String_Bundle.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/2/19.
//

import Foundation

public extension String {
    
    
    static var bundleIdentifier: String? {
        Bundle.main.bundleIdentifier
    }
    
    static var bundleName: String? {
        let dic = Bundle.main.infoDictionary
        return dic?[kCFBundleNameKey as String] as? String
    }
    
    static var bundleRegion: String? {
        let dic = Bundle.main.infoDictionary
        return dic?[kCFBundleDevelopmentRegionKey as String] as? String
    }
    
    static var bundleVersion: String? {
        let dic = Bundle.main.infoDictionary
        return dic?["CFBundleShortVersionString"] as? String
    }
    
    static var buildVersion: String? {
        let dic = Bundle.main.infoDictionary
        return dic?["CFBundleVersion"] as? String
    }
    
    static var bundleMinSysRequire: String? {
        let dic = Bundle.main.infoDictionary
        return dic?["LSMinimumSystemVersion"] as? String
    }
    
    static var sandboxDocument: String? {
        let document = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first?.path
        return document
    }
    
    static var isOpenedSandBox: Bool {
        return NSHomeDirectory().contains("Containers/\(bundleIdentifier!)")
    }
    
    
    static var sandboxSupport: String? {
        let identifier = bundleIdentifier
        let appName = bundleName
        let supportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.path
        if let path = ((supportPath as NSString?)?.appendingPathComponent(identifier!) as NSString?)?.appendingPathComponent(appName!) {
            if !FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("create directory at:\(path) failed")
                }
            }
            return path
        }
        return nil
    }
    
    
    static var sysDocument: String? {
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path
        return docPath
    }
    
    static var sysDocumentApp: String? {
        let doc = sysDocument
        guard let bundleName = bundleName else {
            return nil
        }
        guard let docApp = (doc as NSString?)?.appendingPathComponent(bundleName) else {
            return nil
        }
        if !FileManager.default.fileExists(atPath: docApp) {
            do {
                try FileManager.default.createDirectory(atPath: docApp, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("[DYDebug] create directory at:\(docApp) failed")
            }
        }
        return docApp
    }
    
    static var sandboxTmp : String? {
        if let path = (sandboxSupport as NSString?)?.appendingPathComponent("tmp") {
            if !FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("create directory at:\(path) failed")
                }
            }
            return path
        }
        return nil
    }
    
     
    func versionCompare(to string : String) -> ComparisonResult {
        let selfComponents = components(separatedBy: ".")
        let passedComponents = string.components(separatedBy: ".")
        let minLen = min(selfComponents.count, passedComponents.count)
        for i in stride(from: 0, to: minLen, by: 1) {
            guard let selfValue = Int(selfComponents[i]) else {
                continue
            }
            guard let passedValue = Int(passedComponents[i]) else {
                continue
            }
            if selfValue > passedValue {
                return .orderedDescending
            }else if selfValue == passedValue {
                continue
            }else  {
                return .orderedAscending
            }
        }
        return .orderedSame
    }
    
}
