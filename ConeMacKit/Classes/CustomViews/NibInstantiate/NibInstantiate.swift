//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation
import Cocoa


public enum NibInstantiate<T> {
}

public extension NibInstantiate where T: NSView {
    static func instantiate(withOwner: Any? = nil) -> T {
        let nib = NSNib(nibNamed: "\(T.self)", bundle: nil)
        var topLevelArray: NSArray? = nil
        nib?.instantiate(withOwner: withOwner, topLevelObjects: &topLevelArray)
        guard let results = topLevelArray else {
            fatalError("nib name error")
        }
        if let view = Array<Any>(results).filter({ $0 is T }).first as? T {
            return view
        }
        fatalError("nib name error")
    }
}
 

public extension NibInstantiate where T: NSViewController {
    static func instantiate() -> T {
        let vc = T(nibName: "\(T.self)", bundle: nil)
        return vc
    }
}


open class NibDesignView: NSView {
    
    open var contentView: NSView!
    
    open func classFromString(className: String) -> AnyClass {
        if  let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
            let classStringName = appName + "." + className
            return NSClassFromString(classStringName)!
        }
        fatalError("class name error")
    }
    
    @IBInspectable var nibName: String = "" {
        didSet {
            wantsLayer = true
            layer?.masksToBounds = false
            translatesAutoresizingMaskIntoConstraints = false
            if !nibName.isEmpty {
                let nib = NSNib(nibNamed: nibName, bundle: nil)
                var topLevelArray: NSArray? = nil
                nib?.instantiate(withOwner: nil, topLevelObjects: &topLevelArray)
                guard let results = topLevelArray else {
                    fatalError("nib name error")
                }
                let ViewClass: AnyObject.Type = classFromString(className: nibName)
                if let view = results.first(where: { ($0 as AnyObject).classForCoder == ViewClass.class() }) as? NSView {
                    contentView = view
                    addSubview(view, positioned: .below, relativeTo: nil)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        view.topAnchor.constraint(equalTo: self.topAnchor),
                        view.leftAnchor.constraint(equalTo: self.leftAnchor),
                        view.rightAnchor.constraint(equalTo: self.rightAnchor),
                        view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    ])
                } else {
                    fatalError("nib name error")
                }
            } else {
                fatalError("nib name is emtpy")
            }
        }
    }
    
}
