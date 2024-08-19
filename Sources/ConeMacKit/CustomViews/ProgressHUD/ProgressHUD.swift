//
//  ProgressHUD.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/10.
//

import Foundation
import AppKit


public extension ProgressHUD {
    
    @discardableResult
    static func showHud(addTo view: NSView, animated: Bool = true) -> ProgressHUD {
        if let hud = hud(for: view) {
            return hud
        }
        let hud = ProgressHUD()
        view.addSubview(hud)
        NSLayoutConstraint.activate([
            hud.topAnchor.constraint(equalTo: view.topAnchor),
            hud.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hud.leftAnchor.constraint(equalTo: view.leftAnchor),
            hud.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        return hud
    }
    
    @discardableResult
    static func hide(for view: NSView, animated: Bool = true) -> Bool {
        if let hud = hud(for: view, withSubview: true) {
            hud.hide(animated: animated)
            return true
        }
        return false
    }
    
    static func hud(for view: NSView, withSubview: Bool = false) -> ProgressHUD? {
        if let hud = view.subviews.reversed().first(where: { $0 is ProgressHUD }) as? ProgressHUD {
            return hud
        }
        if withSubview {
            for subview in view.subviews.reversed() {
                if let hud = hud(for: subview) {
                    return hud
                }
            }
        }
        return nil
    }
    
}

public extension ProgressHUD {
    
    func hide(animated: Bool, afterDelay: TimeInterval = 0) {
        
    }
    
}


open class ProgressHUD: NSView {
    
    
    // MARK: - public property
    
    // MARK: - background setting
    
    public enum BackgroundStyle {
        case none
        case color(NSColor)
        case custom(NSView)
    }
    
    /// the style of background
    open var backgroundStyle: BackgroundStyle = .none
    
    /// the display background view
    open var backgroundView: NSView?
    
    
    // MARK: - content setting
    public enum ContentAlignment {
        case top
        case center
        case bottom
    }
     
    open var alignment: ContentAlignment = .center
     
    
    /// content offset
    open var offset: CGPoint = .zero
    
    open var contentEdgeInset: NSEdgeInsets = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    public enum Animation {
        case none
        case fade
        case sheetTop(distance: CGFloat = 8)
    }
    
    /// hud display
    open var animationType: Animation = .none
    
    /// content background color
    open var contentColor: NSColor = .black
    
    open var contentCornerRadius: CGFloat = 8
    
    /// hud min Size
    open var minSize: CGSize = .zero
    
    /// hud max size  if euqal to zero, not limite
    open var maxSize: CGSize = .zero

    private var contentView: ContentView = ContentView()
    
    var indicatorView: NSView?
    
    
    
    // MARK: - private property
    
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configerViews()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    
    public func configerViews() {
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.layer?.cornerRadius = contentCornerRadius
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            contentView.widthAnchor.constraint(equalToConstant: 100),
//            contentView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        
        indicatorView = IndicatorView()
        indicatorView?.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicatorView!)
        NSLayoutConstraint.activate([
            indicatorView!.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentEdgeInset.top),
            indicatorView!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentEdgeInset.bottom),
            indicatorView!.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: contentEdgeInset.left),
            indicatorView!.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentEdgeInset.right)
        ])
    }
    
    
    
    
}



public extension ProgressHUD {
    
    class BackgroundView: NSView {
        
    }
    
}

extension ProgressHUD {
    
    class ContentView: NSView {
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            configerViews()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            configerViews()
        }
        func configerViews() {
            wantsLayer = true
            layer?.backgroundColor = .black
        }
        
        override func mouseDown(with event: NSEvent) {
        }
        override func mouseUp(with event: NSEvent) {
        }
    }
    
}

extension ProgressHUD {
    
    class IndicatorView: NSView {
        
        let indicator = NSProgressIndicator()
        
        lazy var stackView = NSStackView()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            configerViews()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            configerViews()
        }
        
        func configerViews() {
            stackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.leftAnchor.constraint(equalTo: leftAnchor),
                stackView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
              
            indicator.style = .spinning
            indicator.startAnimation(nil)
            stackView.addArrangedSubview(indicator)
        }
        
    }
    
}
