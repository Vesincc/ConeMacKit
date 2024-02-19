//
//  File.swift
//  
//
//  Created by HanQi on 2023/12/19.
//

import Foundation
import Cocoa

public enum CursorArea {
    case all
    case relative(CGRect)
    case absolute(CGRect)
}

public protocol Cursorable {
    
    func addCursor(_ cursor: NSCursor, rect: CursorArea)
    
    func removeAll()
}

public class CursorRect: Cursorable {
    
    fileprivate var cursorInfos: [(cursor: NSCursor, rect: CursorArea)] = []
     
    
    public func addCursor(_ cursor: NSCursor, rect: CursorArea = .all) {
        cursorInfos.append((cursor: cursor, rect: rect))
    }
    
    public func removeAll() {
        cursorInfos = []
    }
     
}

public protocol CursorRectProvider {
    var cursorRect: CursorRect { get }
}

fileprivate var t_cursorRect: Int = 0
extension ViewBehaverWrapper: CursorRectProvider where Base: NSView {
    public var cursorRect: CursorRect {
        guard let cursorRect = objc_getAssociatedObject(base, &t_cursorRect) as? CursorRect else {
            let cursorRect = CursorRect()
            objc_setAssociatedObject(base, &t_cursorRect, cursorRect, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            base.resetCursorRectsAssociated.append { [weak base] in
                guard let v = base else {
                    return
                }
                let rect = v.bounds
                if let cursorRect = objc_getAssociatedObject(v, &t_cursorRect) as? CursorRect, !cursorRect.cursorInfos.isEmpty {
                    for info in cursorRect.cursorInfos {
                        switch info.rect {
                        case .all:
                            v.addCursorRect(rect, cursor: info.cursor)
                        case .relative(let value):
                            v.addCursorRect(CGRect(x: rect.width * value.origin.x, y: rect.height * value.origin.y, width: rect.width * value.width, height: rect.height * value.height), cursor: info.cursor)
                        case .absolute(let value):
                            v.addCursorRect(value, cursor: info.cursor)
                        }
                    }
                }
            }
            return cursorRect
        }
        return cursorRect
    }
     
}
 
