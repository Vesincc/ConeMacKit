//
//  PopoverViewController.swift
//
//
//  Created by HanQi on 2023/11/17.
//

import Cocoa

public struct PopoverConfiger {
    public init(indicatorDirection: WindowPopoverDirection, autoIndicatorDirection: Bool = true, spacing: CGFloat = 10, indicatorHeight: CGFloat = 8, indicatorWidth: CGFloat = 10, indicatorOffset: CGPoint = .zero, cornerRadius: CGFloat = 0, backgroundView: NSView? = nil, backgroundPadding: CGFloat = 0, contentBackgroundView: NSView? = nil, contentEdgeInsets: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), autoHidden: Bool = false) {
        self.indicatorDirection = indicatorDirection
        self.autoIndicatorDirection = autoIndicatorDirection
        self.spacing = spacing
        self.indicatorHeight = indicatorHeight
        self.indicatorWidth = indicatorWidth
        self.indicatorOffset = indicatorOffset
        self.cornerRadius = cornerRadius
        self.backgroundView = backgroundView
        self.backgroundPadding = backgroundPadding
        self.contentBackgroundView = contentBackgroundView
        self.contentEdgeInsets = contentEdgeInsets
        self.autoHidden = autoHidden
    }
    
    
    public var indicatorDirection: WindowPopoverDirection = .bottom
    
    public var autoIndicatorDirection: Bool = true
    
    public var spacing: CGFloat = 10
    
    public var indicatorHeight: CGFloat = 8
    
    public var indicatorWidth: CGFloat = 10
    
    public var indicatorOffset: CGPoint = CGPoint(x: 30, y: 30)
    
    public var cornerRadius: CGFloat = 10

    
    public var backgroundView: NSView?
    
    public var backgroundPadding: CGFloat = 0
    
    public var contentBackgroundView: NSView?
    
    public var contentEdgeInsets: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public var autoHidden: Bool = false
    
}


open class PopoverViewController: NSViewController {
    
    open weak var sourceView: NSView?
    
    open var direction: WindowPopoverDirection = .top
    
    open var configer: PopoverConfiger!
    
    open var backgroundView: NSView?
    
    open var contentBackgroundView: NSView?
    
    open var box: NSBox?
    
    open var contentViewController: NSViewController?
    
    open override func loadView() {
        self.view = NSView(frame:.zero)
    }
 
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contentViewController = contentViewController {
            addChild(contentViewController)
        }
        
        if backgroundView == nil {
            backgroundView = configer.backgroundView ?? NSView(frame: .zero)
            backgroundView?.wantsLayer = true
        }
        
        if contentBackgroundView == nil {
            contentBackgroundView = configer.contentBackgroundView ?? NSView(frame: .zero)
            contentBackgroundView?.wantsLayer = true
        }
        
        guard let backgroundView = backgroundView,
              let contentBackgroundView = contentBackgroundView else {
            return
        }
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
         
        
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(contentBackgroundView)
        
        box = NSBox(frame: .zero)
        box?.contentViewMargins = .zero
        box?.titlePosition = .noTitle
        box?.boxType = .custom
        box?.focusRingType = .none
        box?.borderType = .noBorder
        
        guard let box = box,
              let contentViewController = contentViewController else {
            return
        }
        
        box.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(box)
        box.contentView = contentViewController.view
        
        loadConstraints()
        
    }
    
    
    
    public convenience init(contentViewController: NSViewController, sourceView: NSView?, configer: PopoverConfiger? = nil) {
        self.init()
        self.contentViewController = contentViewController
        self.sourceView = sourceView
        if let configer = configer {
            self.configer = configer
        } else {
            self.configer = .init(indicatorDirection: .top)
        }
        calculateWindowFrame()
    }
     
    
    open override func viewDidLayout() {
        super.viewDidLayout()
        
        addIndicator(at: backgroundView, direction: direction, width: configer.indicatorWidth, height: configer.indicatorHeight, cornerRadius: configer.cornerRadius, offset: configer.indicatorOffset)
        addIndicator(at: contentBackgroundView, direction: direction, width: configer.indicatorWidth, height: configer.indicatorHeight, cornerRadius: configer.cornerRadius, offset: configer.indicatorOffset)
    }
    
    func addIndicator(at view: NSView?, direction: WindowPopoverDirection, width: CGFloat, height: CGFloat, cornerRadius: CGFloat, offset: CGPoint) {
        guard let view = view else {
            return
        }
        var targetRect = view.bounds
        switch direction {
        case .top:
            targetRect = CGRect(x: targetRect.origin.x, y: targetRect.origin.y, width: targetRect.size.width, height: targetRect.size.height - height)
        case .left:
            targetRect = CGRect(x: targetRect.origin.x + height, y: targetRect.origin.y, width: targetRect.size.width - height, height: targetRect.size.height)
        case .right:
            targetRect = CGRect(x: targetRect.origin.x, y: targetRect.origin.y, width: targetRect.size.width - height, height: targetRect.size.height)
        case .bottom:
            targetRect = CGRect(x: targetRect.origin.x, y: targetRect.origin.y + height, width: targetRect.size.width, height: targetRect.size.height - height)
        }
        let path = NSBezierPath()
        
        path.move(to: CGPoint(x: targetRect.minX + cornerRadius, y: targetRect.maxY))
        switch direction {
        case .top:
            path.line(to: CGPoint(x: targetRect.midX + offset.x - (width / 2.0), y: targetRect.maxY))
            path.line(to: CGPoint(x: targetRect.midX + offset.x, y: targetRect.maxY + height))
            path.line(to: CGPoint(x: targetRect.midX + offset.x + (width / 2.0), y: targetRect.maxY))
        default:
            break
        }
        
        path.line(to: CGPoint(x: targetRect.midX + offset.x + (width / 2.0), y: targetRect.maxY))
        path.appendArc(withCenter: CGPoint(x: targetRect.maxX - cornerRadius, y: targetRect.maxY - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 0, clockwise: true)
        
        switch direction {
        case .right:
            path.line(to: CGPoint(x: targetRect.maxX, y: targetRect.midY + offset.y + (width / 2.0)))
            path.line(to: CGPoint(x: targetRect.maxX + height, y: targetRect.midY + offset.y))
            path.line(to: CGPoint(x: targetRect.maxX, y: targetRect.midY + offset.y - (width / 2.0)))
        default:
            break
        }
        path.line(to: CGPoint(x: targetRect.maxX, y: targetRect.minY + cornerRadius))
        path.appendArc(withCenter: CGPoint(x: targetRect.maxX - cornerRadius, y: targetRect.minY + cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 270, clockwise: true)
        
        switch direction {
        case .bottom:
            path.line(to: CGPoint(x: targetRect.midX + offset.x + (width / 2.0), y: targetRect.minY))
            path.line(to: CGPoint(x: targetRect.midX + offset.x, y: targetRect.minY - height))
            path.line(to: CGPoint(x: targetRect.midX + offset.x - (width / 2.0), y: targetRect.minY))
        default:
            break
        }
        
        path.line(to: CGPoint(x: targetRect.minX + cornerRadius, y: targetRect.minY))
        path.appendArc(withCenter: CGPoint(x: targetRect.minX + cornerRadius, y: targetRect.minY + cornerRadius), radius: cornerRadius, startAngle: 270, endAngle: 180, clockwise: true)
        
        switch direction {
        case .left:
            path.line(to: CGPoint(x: targetRect.minX, y: targetRect.midY + offset.y - (width / 2.0)))
            path.line(to: CGPoint(x: targetRect.minX - height, y: targetRect.midY + offset.y))
            path.line(to: CGPoint(x: targetRect.minX, y: targetRect.midY + offset.y + (width / 2.0)))
        default:
            break
        }
        
        path.line(to: CGPoint(x: targetRect.minX, y: targetRect.maxY - cornerRadius))
        path.appendArc(withCenter: CGPoint(x: targetRect.minX + cornerRadius, y: targetRect.maxY - cornerRadius), radius: cornerRadius, startAngle: 180, endAngle: 90, clockwise: true)
        
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        view.layer?.mask = shapeLayer
    }
    
    
}

extension PopoverViewController {
    
    public func loadConstraints() {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        guard let backgroundView = backgroundView,
              let contentBackgroundView = contentBackgroundView,
              let box = box else {
            return
        }
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: direction == .top ? configer.spacing : 0),
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: direction == .left ? configer.spacing : 0),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: direction == .right ? -configer.spacing : 0),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: direction == .bottom ? -configer.spacing : 0)
        ])
        
        NSLayoutConstraint.activate([
            contentBackgroundView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: configer.backgroundPadding),
            contentBackgroundView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -configer.backgroundPadding),
            contentBackgroundView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: configer.backgroundPadding),
            contentBackgroundView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -configer.backgroundPadding)
        ])
        
        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: contentBackgroundView.topAnchor, constant: direction == .top ? configer.contentEdgeInsets.top + configer.indicatorHeight : configer.contentEdgeInsets.top),
            box.bottomAnchor.constraint(equalTo: contentBackgroundView.bottomAnchor, constant: direction == .bottom ? -(configer.contentEdgeInsets.bottom + configer.indicatorHeight) : -configer.contentEdgeInsets.bottom),
            box.leftAnchor.constraint(equalTo: contentBackgroundView.leftAnchor, constant: direction == .left ? configer.contentEdgeInsets.left + configer.indicatorHeight : configer.contentEdgeInsets.left),
            box.rightAnchor.constraint(equalTo: contentBackgroundView.rightAnchor, constant: direction == .right ? -(configer.contentEdgeInsets.right + configer.indicatorHeight) : -configer.contentEdgeInsets.right),
            box.widthAnchor.constraint(equalToConstant: contentViewController?.view.fittingSize.width ?? 0),
            box.heightAnchor.constraint(equalToConstant: contentViewController?.view.fittingSize.height ?? 0)
        ])
         
    }
    
    @discardableResult
    func calculateWindowFrame() -> CGRect {
        guard let _ = sourceView,
              let contentView = contentViewController?.view else {
            return .zero
        }
        let contentViewSize = contentView.fittingSize
        let sourceFrameInWindow = sourceFrameInWindow()
        var targetFrame: CGRect = .zero
        
        let topDirection = { [unowned self] in
            let size = CGSize(width: contentViewSize.width + configer.contentEdgeInsets.left + configer.contentEdgeInsets.right, height: contentViewSize.height + configer.spacing + configer.contentEdgeInsets.top + configer.contentEdgeInsets.bottom + configer.indicatorHeight * 2)
            targetFrame.size = size
            let sizeOffset = CGSize(width: (sourceFrameInWindow.width - size.width) / 2.0, height: (sourceFrameInWindow.height - size.height) / 2.0)
            targetFrame.origin = CGPoint(x: sourceFrameInWindow.origin.x + sizeOffset.width - configer.indicatorOffset.x, y: sourceFrameInWindow.minY - size.height)
            direction = .top
        }
        let leftDirection = { [unowned self] in
            let size = CGSize(width: contentViewSize.width + configer.contentEdgeInsets.left + configer.contentEdgeInsets.right + configer.spacing + configer.indicatorHeight * 2, height: contentViewSize.height + configer.contentEdgeInsets.top + configer.contentEdgeInsets.bottom)
            targetFrame.size = size
            let sizeOffset = CGSize(width: (sourceFrameInWindow.width - size.width) / 2.0, height: (sourceFrameInWindow.height - size.height) / 2.0)
            targetFrame.origin = CGPoint(x: sourceFrameInWindow.maxX, y: sourceFrameInWindow.minY + sizeOffset.height - configer.indicatorOffset.y)
            direction = .left
        }
        let rightDirection = { [unowned self] in
            let size = CGSize(width: contentViewSize.width + configer.contentEdgeInsets.left + configer.contentEdgeInsets.right + configer.spacing + configer.indicatorHeight * 2, height: contentViewSize.height + configer.contentEdgeInsets.top + configer.contentEdgeInsets.bottom)
            targetFrame.size = size
            let sizeOffset = CGSize(width: (sourceFrameInWindow.width - size.width) / 2.0, height: (sourceFrameInWindow.height - size.height) / 2.0)
            targetFrame.origin = CGPoint(x: sourceFrameInWindow.minX - size.width, y: sourceFrameInWindow.minY + sizeOffset.height - configer.indicatorOffset.y)
            direction = .right
        }
        let bottomDirection = { [unowned self] in
            let size = CGSize(width: contentViewSize.width + configer.contentEdgeInsets.left + configer.contentEdgeInsets.right, height: contentViewSize.height + configer.spacing + configer.contentEdgeInsets.top + configer.contentEdgeInsets.bottom + configer.indicatorHeight * 2)
            targetFrame.size = size
            let sizeOffset = CGSize(width: (sourceFrameInWindow.width - size.width) / 2.0, height: (sourceFrameInWindow.height - size.height) / 2.0)
            targetFrame.origin = CGPoint(x: sourceFrameInWindow.origin.x + sizeOffset.width - configer.indicatorOffset.x, y: sourceFrameInWindow.maxY)
            direction = .bottom
        }
        switch configer.indicatorDirection {
        case .top:
            topDirection()
        case .left:
            leftDirection()
            if configer.autoIndicatorDirection, !frameIsInScreen(targetFrame) {
                rightDirection()
            }
            if configer.autoIndicatorDirection, !frameIsInScreen(targetFrame) {
                topDirection()
            }
        case .right:
            rightDirection()
            if configer.autoIndicatorDirection, !frameIsInScreen(targetFrame) {
                leftDirection()
            }
            if configer.autoIndicatorDirection, !frameIsInScreen(targetFrame) {
                topDirection()
            }
        case .bottom:
            bottomDirection()
            if configer.autoIndicatorDirection, !frameIsInScreen(targetFrame) {
                topDirection()
            }
        }
        return targetFrame
    }
    
    func frameIsInScreen(_ frame: CGRect) -> Bool {
        guard let screen = NSScreen.main else {
            return false
        }
        if screen.frame.contains(frame) {
            return true
        }
        return false
    }
    
    func sourceFrameInWindow() -> CGRect {
        guard let view = sourceView else {
            return .zero
        }
        var sourceFrameInWindow = CGRect(origin: view.convert(.zero, to: nil), size: view.frame.size)
        if view.isFlipped {
            sourceFrameInWindow = CGRect(origin: CGPoint(x: sourceFrameInWindow.origin.x, y: sourceFrameInWindow.origin.y - sourceFrameInWindow.size.height), size: sourceFrameInWindow.size)
        }
        sourceFrameInWindow.origin = CGPoint(x: sourceFrameInWindow.origin.x + (view.window?.frame.origin.x ?? 0), y: sourceFrameInWindow.origin.y + (view.window?.frame.origin.y ?? 0))
        return sourceFrameInWindow
    }
    
}
