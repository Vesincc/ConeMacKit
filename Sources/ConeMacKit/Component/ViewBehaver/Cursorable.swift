//
//  File.swift
//  
//
//  Created by HanQi on 2023/12/19.
//

import Foundation
import AppKit 

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
    var cursorDidChanged: (() -> ())?
    
    fileprivate var cursorInfos: [(cursor: NSCursor, rect: CursorArea)] = []
      
    public func addCursor(_ cursor: NSCursor, rect: CursorArea = .all) {
        cursorInfos.append((cursor: cursor, rect: rect))
        cursorDidChanged?()
    }
    
    public func removeAll() {
        cursorInfos = []
        cursorDidChanged?()
    }
     
}

public protocol CursorRectProvider {
    var cursorRect: CursorRect { get }
}

open class ViewBehaverCursorRectView: NSView, CursorRectProvider {
    public var cursorRect: CursorRect = CursorRect()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configerViews()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    func configerViews() {
        cursorRect.cursorDidChanged = { [weak self] in
            if let self = self {
                window?.invalidateCursorRects(for: self)
            }
        }
    }
    open override func resetCursorRects() {
        let disableView = superview?.subviews.first(where: { $0 is ViewBehaverDisableUserInteractionView })
        if disableView == nil {
            let rect = bounds
            for info in cursorRect.cursorInfos {
                switch info.rect {
                case .all:
                    addCursorRect(rect, cursor: info.cursor)
                case .relative(let value):
                    addCursorRect(CGRect(x: rect.width * value.origin.x, y: rect.height * value.origin.y, width: rect.width * value.width, height: rect.height * value.height), cursor: info.cursor)
                case .absolute(let value):
                    addCursorRect(value, cursor: info.cursor)
                }
            }
        }
    }
}

fileprivate var t_cursorRect: Int = 0
extension ViewBehaverWrapper: CursorRectProvider where Base: NSView {
    public var cursorRect: CursorRect {
        if let cursorView = base.subviews.first(where: { $0 is ViewBehaverCursorRectView }) as? ViewBehaverCursorRectView {
            return cursorView.cursorRect
        }
        let new = ViewBehaverCursorRectView()
        new.translatesAutoresizingMaskIntoConstraints = false
        base.addSubview(new)
        NSLayoutConstraint.activate([
            new.topAnchor.constraint(equalTo: base.topAnchor),
            new.bottomAnchor.constraint(equalTo: base.bottomAnchor),
            new.leftAnchor.constraint(equalTo: base.leftAnchor),
            new.rightAnchor.constraint(equalTo: base.rightAnchor)
        ])
        return new.cursorRect
    }
     
}
 
