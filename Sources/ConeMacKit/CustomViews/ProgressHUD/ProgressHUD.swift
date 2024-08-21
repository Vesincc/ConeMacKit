//
//  ProgressHUD.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/10.
//

import Foundation
import AppKit


public extension ProgressHUD {
    
    static func createHud(for view: NSView) -> ProgressHUD {
        hud(for: view, withSubview: false) ?? ProgressHUD()
    }
    
    @discardableResult
    static func hide(for view: NSView, animation: Animation = .fade) -> Bool {
        if let hud = hud(for: view, withSubview: true) {
            hud.hide(animation: animation)
            return true
        }
        return false
    }
    
    private static func hud(for view: NSView, withSubview: Bool) -> ProgressHUD? {
        if let hud = view.subviews.reversed().first(where: { $0 is ProgressHUD }) as? ProgressHUD {
            return hud
        }
        if withSubview {
            for subview in view.subviews.reversed() {
                if let hud = hud(for: subview, withSubview: withSubview) {
                    return hud
                }
            }
        }
        return nil
    }
    
}

public extension ProgressHUD {
    
    func show(in view: NSView, animation: Animation = .sheetTop()) {
        cancelHide()
        animationType = animation
        configerViews()
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func hide(animation: Animation = .fade, afterDelay: TimeInterval = 0) {
        cancelHide()
        animationType = animation
        var hideAnimationDuration: CGFloat = 0
        switch animation {
        case .fade, .sheetBottom(distance: _), .sheetTop(distance: _):
            hideAnimationDuration = 0.25
        default:
            break
        }
        if hideAnimationDuration != 0 {
            self.perform(#selector(hideAnimation), with: nil, afterDelay: afterDelay)
        }
        self.perform(#selector(removeHUD), with: nil, afterDelay: afterDelay + hideAnimationDuration)
    }
    
    func cancelHide() {
        backgroundView?.layer?.removeAnimation(forKey: "hide.backgroundViewAnimation")
        contentView.layer?.removeAnimation(forKey: "hide.contentViewAnimation")
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideAnimation), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(removeHUD), object: nil)
    }
    
    @objc func hideAnimation() {
        switch animationType {
        case .none:
            break
        case .fade:
            let backgroundViewAnimation = CABasicAnimation(keyPath: "opacity")
            backgroundViewAnimation.fromValue = 1
            backgroundViewAnimation.toValue = 0
            backgroundViewAnimation.duration = 0.25
            backgroundViewAnimation.isRemovedOnCompletion = false
            backgroundViewAnimation.fillMode = .both
            backgroundView?.layer?.add(backgroundViewAnimation, forKey: "hide.backgroundViewAnimation")
            
            let contentViewAnimation = CABasicAnimation(keyPath: "opacity")
            contentViewAnimation.fromValue = 1
            contentViewAnimation.toValue = 0
            contentViewAnimation.duration = 0.1
            contentViewAnimation.beginTime = 0.15
            contentViewAnimation.isRemovedOnCompletion = false
            contentViewAnimation.fillMode = .both
            contentView.layer?.add(contentViewAnimation, forKey: "hide.contentViewAnimation")
        case .sheetTop(distance: let distance):
            let backgroundViewAnimation = CABasicAnimation(keyPath: "opacity")
            backgroundViewAnimation.fromValue = 1
            backgroundViewAnimation.toValue = 0
            backgroundViewAnimation.duration = 0.25
            backgroundViewAnimation.isRemovedOnCompletion = false
            backgroundViewAnimation.fillMode = .both
            backgroundView?.layer?.add(backgroundViewAnimation, forKey: "hide.backgroundViewAnimation")
             
            let contentViewAnimation = CAAnimationGroup()
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fromValue = 1
            fadeAnimation.toValue = 0
            let transAnimation = CABasicAnimation(keyPath: "transform")
            transAnimation.fromValue = CATransform3DIdentity
            transAnimation.toValue = CATransform3DMakeTranslation(0, distance, 0)
            transAnimation.timingFunction = .init(name: .easeIn)
            transAnimation.beginTime = 0.1
            contentViewAnimation.animations = [fadeAnimation, transAnimation]
            contentViewAnimation.duration = 0.25
            contentViewAnimation.isRemovedOnCompletion = false
            contentViewAnimation.fillMode = .both
            contentView.layer?.add(contentViewAnimation, forKey: "hide.contentViewAnimation")
        case .sheetBottom(distance: let distance):
            let backgroundViewAnimation = CABasicAnimation(keyPath: "opacity")
            backgroundViewAnimation.fromValue = 1
            backgroundViewAnimation.toValue = 0
            backgroundViewAnimation.duration = 0.25
            backgroundViewAnimation.isRemovedOnCompletion = false
            backgroundViewAnimation.fillMode = .both
            backgroundView?.layer?.add(backgroundViewAnimation, forKey: "hide.backgroundViewAnimation")
             
            let contentViewAnimation = CAAnimationGroup()
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fromValue = 1
            fadeAnimation.toValue = 0
            let transAnimation = CABasicAnimation(keyPath: "transform")
            transAnimation.fromValue = CATransform3DIdentity
            transAnimation.toValue = CATransform3DMakeTranslation(0, -distance, 0)
            transAnimation.timingFunction = .init(name: .easeIn)
            transAnimation.beginTime = 0.1
            contentViewAnimation.animations = [fadeAnimation, transAnimation]
            contentViewAnimation.duration = 0.25
            contentViewAnimation.isRemovedOnCompletion = false
            contentViewAnimation.fillMode = .both
            contentView.layer?.add(contentViewAnimation, forKey: "hide.contentViewAnimation")
        }
    }
    
    @objc func removeHUD() {
        removeFromSuperview()
    }
    
    func showAnimation() {
        guard backgroundView?.layer?.animation(forKey: "show.backgroundViewAnimation") == nil,
              contentView.layer?.animation(forKey: "show.backgroundViewAnimation") == nil else {
            return
        }
        switch animationType {
        case .none:
            break
        case .fade:
            let backgroundViewAnimation = CABasicAnimation(keyPath: "opacity")
            backgroundViewAnimation.fromValue = 0
            backgroundViewAnimation.toValue = 1
            backgroundViewAnimation.duration = 0.25
            backgroundViewAnimation.isRemovedOnCompletion = true
            backgroundView?.layer?.add(backgroundViewAnimation, forKey: "show.backgroundViewAnimation")
            
            let contentViewAnimation = CABasicAnimation(keyPath: "opacity")
            contentViewAnimation.fromValue = 0.2
            contentViewAnimation.toValue = 1
            contentViewAnimation.duration = 0.25
            contentViewAnimation.isRemovedOnCompletion = true
            contentView.layer?.add(contentViewAnimation, forKey: "show.contentViewAnimation")
        case .sheetTop(distance: let distance):
            let backgroundViewAnimation = CABasicAnimation(keyPath: "opacity")
            backgroundViewAnimation.fromValue = 0
            backgroundViewAnimation.toValue = 1
            backgroundViewAnimation.duration = 0.25
            backgroundViewAnimation.isRemovedOnCompletion = true
            backgroundView?.layer?.add(backgroundViewAnimation, forKey: "show.backgroundViewAnimation")
             
            let contentViewAnimation = CAAnimationGroup()
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fromValue = 0.2
            fadeAnimation.toValue = 1
            let transAnimation = CASpringAnimation(keyPath: "transform")
            transAnimation.fromValue = CATransform3DMakeTranslation(0, distance, 0)
            transAnimation.toValue = CATransform3DIdentity
            transAnimation.mass = 0.1
            transAnimation.damping = 5
            transAnimation.initialVelocity = 10
            contentViewAnimation.animations = [fadeAnimation, transAnimation]
            contentViewAnimation.isRemovedOnCompletion = true
            contentView.layer?.add(contentViewAnimation, forKey: "show.contentViewAnimation")
        case .sheetBottom(distance: let distance):
            let backgroundViewAnimation = CABasicAnimation(keyPath: "opacity")
            backgroundViewAnimation.fromValue = 0
            backgroundViewAnimation.toValue = 1
            backgroundViewAnimation.duration = 0.25
            backgroundViewAnimation.isRemovedOnCompletion = true
            backgroundView?.layer?.add(backgroundViewAnimation, forKey: "show.backgroundViewAnimation")
             
            let contentViewAnimation = CAAnimationGroup()
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fromValue = 0.2
            fadeAnimation.toValue = 1
            let transAnimation = CASpringAnimation(keyPath: "transform")
            transAnimation.fromValue = CATransform3DMakeTranslation(0, -distance, 0)
            transAnimation.toValue = CATransform3DIdentity
            transAnimation.mass = 0.1
            transAnimation.damping = 5
            transAnimation.initialVelocity = 10
            contentViewAnimation.animations = [fadeAnimation, transAnimation]
            contentViewAnimation.isRemovedOnCompletion = true
            contentView.layer?.add(contentViewAnimation, forKey: "show.contentViewAnimation")
        }
        
    }
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            showAnimation()
        }
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
    private var backgroundView: NSView?
    
    
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
        case sheetTop(distance: CGFloat = 40)
        case sheetBottom(distance: CGFloat = 40)
    }
    
    /// hud display
    private var animationType: Animation = .none
    
    /// content background color
    open var contentColor: NSColor = .black
    
    open var contentCornerRadius: CGFloat = 8
    
    /// hud min Size
    open var minSize: CGSize = .zero
    
    /// hud max size  if euqal to zero, not limite
    open var maxSize: CGSize = .zero

    private var contentView: ContentView = ContentView()
    
    
    public enum ContentStyle {
        case identity
        case custom(NSView)
    }
    private lazy var indicatorView: NSView = IndicatorView()
    
    open var contentType: ContentStyle = .identity
     
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
     
    
    public func configerViews() {
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
         
        configerBackgroundView()
        configerContentView()
        configerIndicatorView()
         
    }
    
    func configerBackgroundView() {
        self.backgroundView?.removeFromSuperview()
        switch backgroundStyle {
        case .none:
            self.backgroundView = nil
        case .color(let nSColor):
            self.backgroundView = BackgroundView()
            backgroundView?.layer?.backgroundColor = nSColor.cgColor
        case .custom(let nSView):
            backgroundView = nSView
        }
        
        guard let backgroundView = backgroundView else {
            return
        }
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView, positioned: .below, relativeTo: contentView)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: backgroundView.topAnchor),
            leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            rightAnchor.constraint(equalTo: backgroundView.rightAnchor)
        ])
    }
    
    func configerContentView() {
        contentView.wantsLayer = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.superview != nil ? () : addSubview(contentView)
        contentView.layer?.backgroundColor = contentColor.cgColor
        contentView.layer?.cornerRadius = contentCornerRadius
        contentView.constraints.forEach({
            ($0.secondItem as? NSView) != contentView && ($0.firstItem as? NSView) != contentView
        })
        switch alignment {
        case .top:
            NSLayoutConstraint.activate([
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                contentView.topAnchor.constraint(equalTo: topAnchor, constant: offset.y)
            ])
        case .center:
            NSLayoutConstraint.activate([
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y)
            ])
        case .bottom:
            NSLayoutConstraint.activate([
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset.y)
            ])
        }
        if minSize.width > 0 {
            NSLayoutConstraint.activate([contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: minSize.width)])
        }
        if minSize.height > 0 {
            NSLayoutConstraint.activate([contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minSize.height)])
        }
        if maxSize.width > 0 {
            NSLayoutConstraint.activate([contentView.widthAnchor.constraint(lessThanOrEqualToConstant: maxSize.width)])
        }
        if maxSize.height > 0 {
            NSLayoutConstraint.activate([contentView.heightAnchor.constraint(lessThanOrEqualToConstant: maxSize.height)])
        }
        
    }
    
    func configerIndicatorView() {
        switch self.contentType {
        case .identity:
            if indicatorView.superview == nil {
                contentView.addSubview(indicatorView)
            }
            NSLayoutConstraint.activate([
                indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentEdgeInset.top),
                indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentEdgeInset.bottom),
                indicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: contentEdgeInset.left),
                indicatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentEdgeInset.right)
            ])
        case .custom(let nSView):
            nSView.translatesAutoresizingMaskIntoConstraints = false
            indicatorView.removeFromSuperview()
            indicatorView = nSView
            contentView.addSubview(indicatorView)
            NSLayoutConstraint.activate([
                indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentEdgeInset.top),
                indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentEdgeInset.bottom),
                indicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: contentEdgeInset.left),
                indicatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentEdgeInset.right)
            ])
        }
        
    }
      
    
}

fileprivate extension NSView {
    func hasSubview(_ view: NSView) -> Bool {
        if self == view {
            return true
        }
        if subviews.isEmpty {
            return false
        } else {
            return subviews.contains(where: { $0.hasSubview(view) })
        }
    }
}

public extension ProgressHUD {
    
    
    
    class BackgroundView: NSView {
        var localMonitor: Any?
        
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
            NSEvent.addLocalMonitorForEvents(matching: [.mouseEntered, .mouseExited]) { [weak self] event in
                guard let self = self else {
                    return event
                }
                guard self.window?.isKeyWindow ?? false else {
                    return event
                }
                guard let ownerView = event.trackingArea?.owner as? NSView else {
                    return event
                }
                guard let superview = self.superview else {
                    return event
                }
                if superview.hasSubview(ownerView) {
                    return event
                }
                return nil
            }
        }
        deinit {
            if let localMonitor = localMonitor {
                NSEvent.removeMonitor(localMonitor)
            }
        }
        public override func mouseDown(with event: NSEvent) {
        }
        public override func mouseUp(with event: NSEvent) {
        } 
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
        }
        
        override func mouseDown(with event: NSEvent) {
        }
        override func mouseUp(with event: NSEvent) {
        }
    }
    
}

public extension ProgressHUD {
    
    open var font: NSFont? {
        get {
            (indicatorView as? IndicatorView)?.label.font
        }
        set {
            (indicatorView as? IndicatorView)?.label.font = newValue
        }
    }
    
    open var text: String? {
        get {
            (indicatorView as? IndicatorView)?.label.stringValue
        }
        set {
            (indicatorView as? IndicatorView)?.label.stringValue = newValue ?? ""
            (indicatorView as? IndicatorView)?.label.isHidden = (newValue ?? "").isEmpty
        }
    }
    
    open var textColor: NSColor? {
        get {
            (indicatorView as? IndicatorView)?.label.textColor
        }
        set {
            (indicatorView as? IndicatorView)?.label.textColor = newValue
        }
    }
    
    open var image: NSImage? {
        get {
            (indicatorView as? IndicatorView)?.imageView.image
        }
        set {
            (indicatorView as? IndicatorView)?.imageView.image = newValue
        }
    }
    
    open var textAligment: NSTextAlignment? {
        get {
            (indicatorView as? IndicatorView)?.label.alignment
        }
        set {
            (indicatorView as? IndicatorView)?.label.alignment = newValue ?? .center
        }
    }
    
    open var indicator: NSProgressIndicator? {
        get {
            (indicatorView as? IndicatorView)?.indicator
        }
    }
    
    open var isHideIndicator: Bool {
        get {
            (indicatorView as? IndicatorView)?.indicator.isHidden ?? true
        }
        set {
            (indicatorView as? IndicatorView)?.indicator.isHidden = newValue
        }
    }
    
    open var isHideImage: Bool {
        get {
            (indicatorView as? IndicatorView)?.imageView.isHidden ?? true
        }
        set {
            (indicatorView as? IndicatorView)?.imageView.isHidden = newValue
        }
    }
    
    open var contentStackView: NSStackView? {
        get {
            (indicatorView as? IndicatorView)?.stackView
        }
    }
    
    open var contentIndicatorView: IndicatorView? {
        get {
            indicatorView as? IndicatorView
        }
    }
    
    open class IndicatorView: NSView {
        
        public let indicator = NSProgressIndicator()
        
        open lazy var imageView = {
            let imageView = NSImageView()
            imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            return imageView
        }()
        
        open lazy var label = {
            let label = NSTextField(wrappingLabelWithString: "Loading...")
            label.font = NSFont.systemFont(ofSize: 14)
            label.textColor = NSColor.white
            label.isSelectable = false
            label.alignment = .center
            label.lineBreakMode = .byWordWrapping
            return label
        }()
        
        public lazy var stackView = NSStackView()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            configerViews()
        }
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
            configerViews()
        }
        
        open func configerViews() {
            translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.leftAnchor.constraint(equalTo: leftAnchor),
                stackView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
            stackView.spacing = 8
            indicator.style = .spinning
            indicator.startAnimation(nil)
            stackView.addArrangedSubview(indicator)
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
        }
        
    }
    
}
