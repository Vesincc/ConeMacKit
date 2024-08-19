//
//  ResizeableView.swift
//  Wipit
//
//  Created by 冯丹阳 on 2024/2/28.
//

import AppKit
import Carbon

public struct DirectionOption : OptionSet {
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public let rawValue: Int
    
    public static let left = DirectionOption(rawValue: 1)
    
    public static let right = DirectionOption(rawValue: 2)
    
    public static let top = DirectionOption(rawValue: 4)

    public static let bottom = DirectionOption(rawValue: 8)
}

// MARK: 代理
@objc public protocol ResizeableViewDelegate : NSObjectProtocol {
    
    @objc optional func resizeableViewDidUpdateFrame()
    
}
// MARK: 可调整的view
open class ResizeableView: NSView {
    
    @IBOutlet open var delegate : ResizeableViewDelegate?
    
    /// 是否可以交互
    open var isInteractive : Bool = true
    
    /// 键盘事件是否可以调整frame。
    open var acceptKeydownControl : Bool = false
    
    /// 是否展示边控制点.
    open var displaySideControl : Bool = true {
        didSet {
            sideControl.isHidden = !displaySideControl
        }
    }
    /// 控制点的大小.
    open var controlSize = NSSize(width: 12, height: 12)
    
    /// 最小尺寸。
    open var minSize = NSSize(width: 26, height: 26)
    
    // 是否比例拖动.
    open var ratio : Double?
    
    /// 控制点的颜色
    open var controlColor : NSColor = NSColor(named: "AccentColor") ?? NSColor.blue {
        didSet {
            layer?.borderColor = controlColor.cgColor
            cornerControl.strokeColor = controlColor.cgColor
            sideControl.strokeColor = controlColor.cgColor
            seperatorLayer.strokeColor = controlColor.cgColor
        }
    }
    private var mouseMoveDirection : DirectionOption = []

    private let cornerControl = CAShapeLayer()
    
    private let sideControl = CAShapeLayer()
    
    private let seperatorLayer = CAShapeLayer()
    
    private var preValue : NSRect?
    
    private var localMonitor : Any?
    
    open override var frame: NSRect {
        didSet {
            updateSubTree()
        }
    }
    /// 是否高亮状态
    open var isHighlighted: Bool = false {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            cornerControl.isHidden = isHidden || !isHighlighted || !isInteractive
            CATransaction.commit()
        }
    }
    open override var isHidden: Bool {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            cornerControl.isHidden = isHidden || !isHighlighted || !isInteractive
            CATransaction.commit()
        }
    }
    
    private var direction : DirectionOption = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initial()
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initial()
    }
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        updateResizeAnchor()
        if let scrollView = enclosingScrollView {
            scrollView.addObserver(self, forKeyPath: "magnification", options: .new, context: nil)
        }
    }
    deinit {
        removeLocalMonitor()
        if let scrollView = enclosingScrollView {
            scrollView.removeObserver(self, forKeyPath: "magnification")
        }
    }
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object as? NSScrollView else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if object == enclosingScrollView && keyPath == "magnification" {
            updateResizeAnchor()
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}
// MARK: Undo
extension ResizeableView {
    func undoFrame(_ frame : NSRect) {
        undoManager?.registerUndo(withTarget: self, handler: { wself in
            wself.undoFrame(self.frame)
            wself.frame = frame
            wself.delegate?.resizeableViewDidUpdateFrame?()
        })
        NotificationCenter.default.post(name: NSNotification.Name.NSUndoManagerDidUndoChange, object: undoManager)
    }
}
// MARK: 事件
extension ResizeableView {
    open override func cursorUpdate(with event: NSEvent) {
        
    }
    open override func hitTest(_ point: NSPoint) -> NSView? {
        if !isInteractive {
            return nil
        }
        if isHighlighted {
            if direction == [.top,.left] || direction == [.top,.right] || direction == [.bottom,.left] || direction == [.top,.right] {
                return self
            }
            let dir = directionOfLocationRect(rect: frame, location: point)
            if dir == [.top,.left] || dir == [.top,.right] || dir == [.bottom,.left] || dir == [.top,.right] {
                return self
            }
            if ratio == nil && (dir == .left || dir == .right || dir == .top || dir == .bottom) {
                return self
            }
        }
        if frame.contains(point) {
            return super.hitTest(point)
        }
        return nil
    }
    open override func mouseDown(with event: NSEvent) {
        isHighlighted = true
        guard let location = superview?.convert(event.locationInWindow, from: nil) else {
            return
        }
        if location.distance(to: NSPoint(x: frame.minX, y: frame.maxY)) <= _controlSize.width {
            direction = [.top,.left]
        }else if location.distance(to: NSPoint(x: frame.maxX, y: frame.maxY)) <= _controlSize.width {
            direction = [.top,.right]
        }else if location.distance(to: NSPoint(x: frame.maxX, y: frame.minY)) <= _controlSize.width {
            direction = [.bottom,.right]
        }else if location.distance(to: NSPoint(x: frame.minX, y: frame.minY)) <= _controlSize.width {
            direction = [.bottom,.left]
        }else if ratio == nil && abs(location.x - frame.minX) <= (_controlSize.width * 0.5) && location.y >= frame.minY && location.y <= frame.maxY {
            direction = .left
        }else if ratio == nil && abs(location.x - frame.maxX) <= (_controlSize.width * 0.5) && location.y >= frame.minY && location.y <= frame.maxY {
            direction = .right
        }else if ratio == nil && abs(location.y - frame.minY) <= (_controlSize.height * 0.5) && location.x >= frame.minX && location.x <= frame.maxX {
            direction = .bottom
        }else if ratio == nil && abs(location.y - frame.maxY) <= (_controlSize.height * 0.5) && location.x >= frame.minX && location.x <= frame.maxX {
            direction = .top
        }else {
            direction = [.left,.right,.top,.bottom]
        }
        preValue = frame
    }
    open override func mouseDragged(with event: NSEvent) {
        if direction == [.left,.right,.top,.bottom] {
            dragMove(event: event)
        }else {
            dragResize(event: event)
        }
    }
    open override func mouseUp(with event: NSEvent) {
        if direction == [.left,.right,.top,.bottom] {
            dragMove(event: event)
        }else {
            dragResize(event: event)
        }
        direction = []
        window?.invalidateCursorRects(for: self)
        if preValue == nil || preValue == frame {
            return
        }
        undoFrame(preValue!)
        preValue = nil
    }
}
// MARK: 私有方法
extension ResizeableView {
    
    var _controlSize : NSSize {
        let magnification = enclosingScrollView?.magnification ?? 1
        return CGSize(width: controlSize.width / magnification, height: controlSize.height / magnification)
    }
    var _minSize : NSSize {
        let magnification = enclosingScrollView?.magnification ?? 1
        return CGSize(width: minSize.width / magnification, height: minSize.height / magnification)
    }
    private func initial() {
        wantsLayer = true
        
        layer?.masksToBounds = false
        layer?.borderColor = controlColor.cgColor
        layer?.borderWidth = 1
        
        cornerControl.fillColor = NSColor.clear.cgColor
        cornerControl.strokeColor = controlColor.cgColor
        cornerControl.lineWidth = 4
        
        sideControl.fillColor = NSColor.clear.cgColor
        sideControl.strokeColor = controlColor.cgColor
        sideControl.lineWidth = 4
        
        seperatorLayer.fillColor = NSColor.clear.cgColor
        seperatorLayer.strokeColor = controlColor.cgColor
        seperatorLayer.lineWidth = 1
         
        layer?.addSublayer(cornerControl)
        layer?.addSublayer(sideControl)
        layer?.addSublayer(seperatorLayer)

        updateSubTree()
        
        isHighlighted = true
        
        addLocalMonitor()
    }
    private func addLocalMonitor() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved,.keyDown], handler: { [weak self] eve in
            if eve.type == .keyDown {
                self?.keyDown(with: eve)
            }else {
                self?.mouseDirectionOfEvent(eve)
            }
            return eve
        })
    }
    private func removeLocalMonitor() {
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }
    private func updateSubTree() {
        updateResizeAnchor()
    }
    open override func keyDown(with event: NSEvent) {
        if !acceptKeydownControl {
            return
        }
        if mouseMoveDirection == [] {
            super.keyDown(with: event)
            return
        }
        var toframe = frame
        
        if ratio == nil && mouseMoveDirection == .left {
            if event.keyCode == kVK_LeftArrow {
                toframe.origin.x -= 1
                toframe.size.width += 1
            }else if event.keyCode == kVK_RightArrow {
                toframe.origin.x += 1
                toframe.size.width -= 1
            }
        }else if ratio == nil && mouseMoveDirection == .right {
            if event.keyCode == kVK_LeftArrow {
                toframe.size.width -= 1
            }else if event.keyCode == kVK_RightArrow {
                toframe.size.width += 1
            }
        }else if ratio == nil && mouseMoveDirection == .top {
            if event.keyCode == kVK_UpArrow {
                toframe.size.height += 1
            }else if event.keyCode == kVK_DownArrow {
                toframe.size.height -= 1
            }
        }else if ratio == nil && mouseMoveDirection == .bottom {
            if event.keyCode == kVK_UpArrow {
                toframe.origin.y += 1
                toframe.size.height -= 1
            }else if event.keyCode == kVK_DownArrow {
                toframe.origin.y -= 1
                toframe.size.height += 1
            }
        }else {
            if event.keyCode == kVK_UpArrow {
                toframe.origin.y += 1
            }else if event.keyCode == kVK_DownArrow {
                toframe.origin.y -= 1
            }else if event.keyCode == kVK_LeftArrow {
                toframe.origin.x -= 1
            }else if event.keyCode == kVK_RightArrow {
                toframe.origin.x += 1
            }
        }
        toframe.origin.x = max(toframe.origin.x, 0)
        toframe.origin.x = min(toframe.origin.x, superview!.bounds.width - toframe.width)
        toframe.origin.y = max(toframe.origin.y, 0)
        toframe.origin.y = min(toframe.origin.y, superview!.bounds.height - toframe.height)
        frame = toframe
        
        // 移动鼠标
        var mousePoint = CGEvent(source: nil)?.location ?? NSEvent.mouseLocation
        if event.keyCode == kVK_LeftArrow {
            mousePoint.x -= 1
        }else if event.keyCode == kVK_RightArrow {
            mousePoint.x += 1
        }else if event.keyCode == kVK_DownArrow {
            mousePoint.y += 1
        }else if event.keyCode == kVK_UpArrow {
            mousePoint.y -= 1
        }
        CGWarpMouseCursorPosition(mousePoint)
    }
    func dragResize(event : NSEvent) {
        // 缩放
        if (direction == .left || direction == .right || direction == .top || direction == .bottom) && ratio != nil {
            // 比例拖动不能调整边。
            return
        }
        let resizeOption = direction
        var deltaX = event.deltaX
        var deltaY = event.deltaY

        if resizeOption.contains(.left) {
            // contain left
            deltaX = -event.deltaX
        }else if resizeOption.contains(.right) {
            // contain right
            deltaX = event.deltaX
        }
        if resizeOption.contains(.bottom) {
            // contain bottom
            deltaY = event.deltaY
        }else if resizeOption.contains(.top) {
            // contain top
            deltaY = -event.deltaY
        }
        let magnification = enclosingScrollView?.magnification ?? 1
        deltaX = deltaX / magnification
        deltaY = deltaY / magnification
        
        
      
        var x = frame.minX
        var y = frame.minY
        var w = frame.width
        var h = frame.height
        
        if resizeOption.contains(.left) {
            // contain left
            x = max(frame.minX - deltaX, 0)
            w = min(frame.width + deltaX, frame.maxX)
        }else if resizeOption.contains(.right) {
            // contain right
            w = min(frame.width + deltaX, superview!.bounds.width - frame.minX)
        }
        if resizeOption.contains(.bottom) {
            // contain bottom
            y = max(frame.minY - deltaY,0)
            h = min(frame.height + deltaY, frame.maxY)
        }else if resizeOption.contains(.top) {
            // contain top
            h = min(frame.height + deltaY, superview!.bounds.height - frame.minY)
        }
        // 最小限制.
        w = max(_minSize.width, w)
        h = max(_minSize.height, h)
        // 比例限制
        if let ratio = ratio {
            if superview!.bounds.width / superview!.bounds.height > ratio {
                w = h * ratio
            }else {
                h = w / ratio
            }
        }
        // 根据限制宽高重新计算x，y
        if resizeOption.contains(.left) {
            // contain left
            x = max(frame.maxX - w, 0)
        }
        if resizeOption.contains(.bottom) {
            // contain bottom
            y = max(frame.maxY - h,0)
        }
        frame = CGRect(x: x, y: y, width: w, height: h)
        delegate?.resizeableViewDidUpdateFrame?()
    }
    func dragMove(event : NSEvent) {
        let magnification = enclosingScrollView?.magnification ?? 1
        var toframe = frame
        toframe.origin.x += (event.deltaX / magnification)
        if superview?.isFlipped ?? false {
            toframe.origin.y += (event.deltaY / magnification)
        }else {
            toframe.origin.y -= (event.deltaY / magnification)
        }
        // 限制移动不能超过父视图.
        toframe.origin.x = max(toframe.origin.x, 0)
        toframe.origin.x = min(toframe.origin.x, superview!.bounds.width - toframe.width)
        toframe.origin.y = max(toframe.origin.y, 0)
        toframe.origin.y = min(toframe.origin.y, superview!.bounds.height - toframe.height)
        frame = toframe
        delegate?.resizeableViewDidUpdateFrame?()
    }
    /// 根据传入event判断当前的鼠标所在的方向
    func mouseDirectionOfEvent(_ event : NSEvent) {
        if !isInteractive {
            mouseMoveDirection = []
        }
        let point = convert(event.locationInWindow, from: nil)
        
        mouseMoveDirection = directionOfLocationRect(rect: bounds, location: point)
        
        if mouseMoveDirection == [] {
            NSCursor.arrow.set()
        }
        if mouseMoveDirection == [.top,.left] || mouseMoveDirection == [.bottom,.right] {
            NSCursor.nwse.set()
        }else if mouseMoveDirection == [.top,.right]  || mouseMoveDirection == [.bottom,.left]  {
            NSCursor.nesw.set()
        }else if ratio == nil && (mouseMoveDirection == .left || mouseMoveDirection == .right) {
            NSCursor.resizeLeftRight.set()
        }else if ratio == nil && (mouseMoveDirection == .top || mouseMoveDirection == .bottom) {
            NSCursor.resizeUpDown.set()
        }else {
            NSCursor.openHand.set()
        }
    }
    func directionOfLocationRect(rect : NSRect,location : NSPoint) -> DirectionOption {
        // 1.判断是否点击拖拽resize 区域.
        if location.distance(to: NSPoint(x: rect.minX , y: rect.maxY)) <= _controlSize.width {
            return [.top,.left]
        }else if location.distance(to: NSPoint(x: rect.maxX , y: rect.maxY)) <= _controlSize.width {
            return [.top,.right]
        }else if location.distance(to: NSPoint(x: rect.maxX , y: rect.minY)) <= _controlSize.width {
            return [.bottom,.right]
        }else if location.distance(to: NSPoint(x: rect.minX , y: rect.minY)) <= _controlSize.width {
            return [.bottom,.left]
        }
        if ratio == nil {
            // 边
            if abs(location.x - rect.minX) <= (_controlSize.width * 0.5) && location.y >= rect.minY && location.y <= rect.maxY {
                return .left
            }
            if abs(location.x - rect.maxX) <= _controlSize.width * 0.5 && location.y >= rect.minY && location.y <= rect.maxY {
                return .right
            }
            if abs(location.y - rect.minY) <= (_controlSize.height * 0.5) && location.x >= rect.minX && location.x <= rect.maxX {
                return .bottom
            }
            if abs(location.y - rect.maxY) <= (_controlSize.height * 0.5) && location.x >= rect.minX && location.x <= rect.maxX {
                return .top
            }
        }
        if rect.contains(location) {
            return [.left,.right,.top,.bottom]
        }
        return []
    }
    /// 绘制控制点
    func updateResizeAnchor() {
        let cornerControlPath = NSBezierPath()
        
        let magnification : CGFloat = enclosingScrollView?.magnification ?? 1
        
        let cornerControlLineWidth = 4.0 / magnification
        
        // 左下
        cornerControlPath.move(to: NSPoint(x: bounds.minX + cornerControlLineWidth * 0.5, y: bounds.minY + _controlSize.height))
        cornerControlPath.line(to: NSPoint(x: bounds.minX + cornerControlLineWidth * 0.5, y: bounds.minY + cornerControlLineWidth * 0.5))
        cornerControlPath.line(to: NSPoint(x: bounds.minX + _controlSize.width, y: bounds.minY + cornerControlLineWidth * 0.5))
        
        // 右下
        cornerControlPath.move(to: NSPoint(x: bounds.maxX - _controlSize.width, y: bounds.minY + cornerControlLineWidth * 0.5))
        cornerControlPath.line(to: NSPoint(x: bounds.maxX - cornerControlLineWidth * 0.5, y: bounds.minY + cornerControlLineWidth * 0.5))
        cornerControlPath.line(to: NSPoint(x: bounds.maxX - cornerControlLineWidth * 0.5, y: bounds.minY + _controlSize.height))
        
        // 右上
        cornerControlPath.move(to: NSPoint(x: bounds.maxX - cornerControlLineWidth * 0.5, y: bounds.maxY - _controlSize.height))
        cornerControlPath.line(to: NSPoint(x: bounds.maxX - cornerControlLineWidth * 0.5, y: bounds.maxY - cornerControlLineWidth * 0.5))
        cornerControlPath.line(to: NSPoint(x: bounds.maxX - _controlSize.width, y: bounds.maxY - cornerControlLineWidth * 0.5))
        
        // 左上
        cornerControlPath.move(to: NSPoint(x: bounds.minX + _controlSize.width, y: bounds.maxY - cornerControlLineWidth * 0.5))
        cornerControlPath.line(to: NSPoint(x: bounds.minX + cornerControlLineWidth * 0.5, y: bounds.maxY - cornerControlLineWidth * 0.5))
        cornerControlPath.line(to: NSPoint(x: bounds.minX + cornerControlLineWidth * 0.5, y: bounds.maxY - _controlSize.height))
        
        // 旋转path
        cornerControl.path = cornerControlPath.cgPath
        cornerControl.lineWidth = cornerControlLineWidth
        
        let sideControlPath = NSBezierPath()
        let sideControlLineWidth = 5.0 / magnification
        // 左边
        sideControlPath.move(to: NSPoint(x: bounds.minX, y: bounds.midY - _controlSize.height * 0.5))
        sideControlPath.line(to: NSPoint(x: bounds.minX, y: bounds.midY + _controlSize.height * 0.5))
        
        // 下边
        sideControlPath.move(to: NSPoint(x: bounds.midX - _controlSize.width * 0.5, y: bounds.minY))
        sideControlPath.line(to: NSPoint(x: bounds.midX + _controlSize.width * 0.5, y: bounds.minY))
        
        // 右边
        sideControlPath.move(to: NSPoint(x: bounds.maxX, y: bounds.midY - _controlSize.height * 0.5))
        sideControlPath.line(to: NSPoint(x: bounds.maxX, y: bounds.midY + _controlSize.height * 0.5))

        // 上边
        sideControlPath.move(to: NSPoint(x: bounds.midX - _controlSize.width * 0.5, y: bounds.maxY))
        sideControlPath.line(to: NSPoint(x: bounds.midX + _controlSize.width * 0.5, y: bounds.maxY))
        
        
        sideControl.path = sideControlPath.cgPath
        sideControl.lineWidth = sideControlLineWidth
        
        // 绘制中间分割线
        let seperatorPath = NSBezierPath()
        for h in 1 ..< 3 {
            seperatorPath.move(to: CGPoint(x: bounds.minX, y: bounds.minY + bounds.height * (CGFloat(h) / 3.0)))
            seperatorPath.line(to: CGPoint(x: bounds.maxX, y: bounds.minY + bounds.height * (CGFloat(h) / 3.0)))
        }
        for v in 1 ..< 3 {
            seperatorPath.move(to:CGPoint(x: bounds.minX + bounds.width * (CGFloat(v) / 3.0), y: bounds.minY))
            seperatorPath.line(to:CGPoint(x: bounds.minX + bounds.width * (CGFloat(v) / 3.0), y: bounds.maxY))
        }
        seperatorLayer.path = seperatorPath.cgPath
        seperatorLayer.lineWidth = 1.0 / magnification
        seperatorLayer.lineDashPattern = [NSNumber(value: 3.0 / magnification),
                                          NSNumber(value: 6.0 / magnification)]
    }
}
