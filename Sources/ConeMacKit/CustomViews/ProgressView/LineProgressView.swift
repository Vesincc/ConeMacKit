//
//  LineProgressView.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/9.
//

import AppKit

open class LineProgressView: NSView {
    
     
    // MARK: - interface builder
    
    @IBInspectable open var maxProgress: Float = 1
    
    @IBInspectable open var progress: Float = 0 {
        didSet {
            configerLayers()
        }
    }
    
    
    /// 进度颜色
    @IBInspectable open var barTintColor: NSColor? {
        get {
            guard let color = progressLayer.backgroundColor else {
                return nil
            }
            return NSColor(cgColor: color)
        }
        set {
            let color = newValue ?? .clear
            progressLayer.colors = [color, color].map({ $0.cgColor })
        }
    }
    
    /// 背景颜色
    @IBInspectable open var trackColor: NSColor? {
        get {
            if let color = trackLayer.backgroundColor {
                return NSColor(cgColor: color)
            }
            return nil
        }
        set {
            trackLayer.backgroundColor = newValue?.cgColor
        }
    }
    
    /// 圆角
    @IBInspectable open var progressCornerRadius: CGFloat {
        get {
            progressLayer.cornerRadius
        }
        set {
            progressLayer.cornerRadius = newValue
            trackLayer.cornerRadius = newValue
        }
    }
    
    
    // MARK: - propertys
    
    open var colors: [NSColor] = [NSColor(rgb: 0x3FE8A1), NSColor(rgb: 0x3FE8A1)] {
        didSet {
            progressLayer.colors = colors.map({ $0.cgColor })
        }
    }
    
    open var locations: [NSNumber]? {
        didSet {
            progressLayer.locations = locations
        }
    }
    
    lazy open var progressLayer: CAGradientLayer = Setter(CAGradientLayer())
        .startPoint(CGPoint(x: 0, y: 0))
        .endPoint(CGPoint(x: 1, y: 0))
        .colors(colors.map({ $0.cgColor }))
        .subject
    
    lazy open var trackLayer: CAShapeLayer = Setter(CAShapeLayer())
        .subject
    

    
    // MARK: - life cycel

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configers()
    }
    
    
    open override func layout() {
        super.layout()
        configerLayers(animation: false)
    }
    
    open func configers() {
        wantsLayer = true
        layer?.addSublayer(trackLayer)
        layer?.addSublayer(progressLayer)
        
        configerLayers(animation: false)
    }
    
    open func configerLayers(animation: Bool = true) {
        if !animation {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        let maxWidth = bounds.size.width
        let currentWidth = maxWidth * CGFloat(progress / maxProgress)
        trackLayer.frame = bounds
        progressLayer.frame = CGRect(origin: .zero, size: CGSize(width: currentWidth, height: bounds.height))
        if !animation {
            CATransaction.commit()
        }
    }
    
}
