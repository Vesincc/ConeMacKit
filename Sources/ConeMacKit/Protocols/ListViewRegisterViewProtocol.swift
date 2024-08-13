//
//  ListViewRegisterViewProtocol.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import Foundation
import AppKit

public protocol ListViewRegisterViewProtocol {
    associatedtype Cell
    
    func registerCellNib<Cell>(_ aClass: Cell.Type)
    func makeView<Cell>(_ aClass: Cell.Type, owner: Any?) -> Cell
    
}

extension NSTableView: ListViewRegisterViewProtocol {
    public typealias Cell = NSTableCellView
    
    public func registerCellNib<Cell>(_ aClass: Cell.Type) {
        let name = String(describing: aClass)
        let bundle = Bundle(for: aClass as! AnyClass)
        let nib = NSNib(nibNamed: name, bundle: bundle)
        register(nib, forIdentifier: NSUserInterfaceItemIdentifier(name))
    }
    
    public func makeView<Cell>(_ aClass: Cell.Type, owner: Any?) -> Cell {
        let name = String(describing: aClass)
        guard let cell = makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: name), owner: owner) as? Cell else {
            fatalError("\(name) is not registed")
        }
        return cell
    }
    
}
