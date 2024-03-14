//
//  NSTableView_Kit.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import Cocoa
 
public extension NSTableView {
    
    fileprivate enum TableViewEmptyAssociatedObject {
        static var isChangedReloadData = false
        static var tableEmptyViewEnableKey = malloc(1)!
        static var tableEmptyViewKey = malloc(1)!
    }

    var tableEmptyViewEnable: Bool {
        get {
            objc_getAssociatedObject(self, TableViewEmptyAssociatedObject.tableEmptyViewEnableKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, TableViewEmptyAssociatedObject.tableEmptyViewEnableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            changeMethod()
        }
    }
    
    var tableEmptyView: NSView? {
        get {
            objc_getAssociatedObject(self, TableViewEmptyAssociatedObject.tableEmptyViewKey) as? NSView
        }
        set {
            objc_setAssociatedObject(self, TableViewEmptyAssociatedObject.tableEmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

fileprivate extension NSTableView {
    
    func changeMethod() {
        guard !TableViewEmptyAssociatedObject.isChangedReloadData else {
            return
        }
        TableViewEmptyAssociatedObject.isChangedReloadData = true
        NSObject.swizzleMethod(
            for: NSTableView.self,
            originalSelector: #selector(NSTableView.reloadData as (NSTableView) -> () -> Void),
            swizzledSelector: #selector(NSTableView.tableEmptyView_reloadData)
        )
    }
    
    
    @objc func tableEmptyView_reloadData() {
        tableEmptyView_reloadData()
        guard tableEmptyViewEnable, let emptyView = tableEmptyView else {
            return
        }
        let count = self.numberOfRows
        if emptyView.superview == nil {
            addSubview(emptyView)
        }
        emptyView.frame = emptyView.superview?.bounds ?? .zero
        if count > 0 {
            emptyView.isHidden = true
        } else {
            emptyView.isHidden = false
        }
    }
    
}
