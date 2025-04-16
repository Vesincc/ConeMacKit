//
//  ConeSlider.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/9.
//

import AppKit
 
open class ConeSlider : NSControl {
    
    public enum ValueState {
        case begin
        case change
        case end
    }
    
    private let animationHighlightedKey = "animation.slider.highlighted"
    
    private let animationDeHighlightedKey = "animation.slider.dehighlighted"

    enum TouchLocation {
        case out
        case knob
        case track
    }
    
    open var minValue : Double = 0 {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            updateProgress()
            CATransaction.commit()
            if value <= minValue {
                value = minValue
            }
        }
    }
    
    open var maxValue : Double = 1 {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            updateProgress()
            CATransaction.commit()
            if value >= maxValue {
                value = maxValue
            }
        }
    }
    
    open var value : Double = 0 {
        didSet {
            updateProgress()
        }
    }
    public var valueState : ValueState = .begin
    
    public var optionValues : [Any]? {
        didSet {
            if let optionValues = optionValues,
               !optionValues.isEmpty {
                maxValue = Double(optionValues.count - 1)
            }
        }
    }
    public var optionValue : Any? {
        if let optionValues = optionValues {
            return optionValues[Int(value)]
        }
        return nil
    }
    
    private let knobLayer = CALayer()
    
    private let dotLayer = CALayer()
    
    private let tintLayer = CALayer()
    
    private let trackLayer = CALayer()
    
    private var touchLocation = TouchLocation.out
    
    private var dragStartLocation : NSPoint?
    private var dragStartProgress : Double?
    
    
    
    
    /// 轨道颜色
    @IBInspectable open var trackColor : NSColor = NSColor.lightGray {
        didSet {
            trackLayer.backgroundColor = trackColor.cgColor
        }
    }
     
    @IBInspectable open var tintColor : NSColor = NSColor.blue {
        didSet {
            tintLayer.backgroundColor = tintColor.cgColor
        }
    }
    
    /// 滑块颜色
    @IBInspectable open var knobColor : NSColor = NSColor.white {
        didSet {
            knobLayer.backgroundColor = knobColor.cgColor
        }
    }
    
    /// 滑块中心点颜色
    @IBInspectable open var dotColor : NSColor = NSColor.white {
        didSet {
            dotLayer.backgroundColor = dotColor.cgColor
        }
    }

    open var totalWidth : CGFloat {
        return max(bounds.width, bounds.height) - knobWidth
    }
    
    open var knobWidth : CGFloat {
        return min(bounds.width, bounds.height)
    }
    
    open var trackHeight : CGFloat = 6
    
    open var dotBorderWidth : CGFloat = 3
    
    open override var frame: NSRect {
        didSet {
            initialSubTree()
            updateProgress()
        }
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _initial()
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        _initial()
    }
    
    private func _initial() {
        wantsLayer = true

        trackLayer.backgroundColor = trackColor.cgColor
        layer?.addSublayer(trackLayer)
        
        tintLayer.backgroundColor = tintColor.cgColor
        trackLayer.addSublayer(tintLayer)
        
        knobLayer.backgroundColor = knobColor.cgColor
        layer?.addSublayer(knobLayer)
        
        dotLayer.backgroundColor = dotColor.cgColor
        knobLayer.addSublayer(dotLayer)
    
        initialSubTree()
    }
    private func initialSubTree() {
        if bounds.width > bounds.height {
            trackLayer.frame = NSRect(origin: NSPoint(x: 0, y: (bounds.height - trackHeight) * 0.5), size: NSSize(width: bounds.width, height: trackHeight))
            tintLayer.frame = NSRect(origin: .zero, size: NSSize(width: 0, height: trackLayer.frame.height))
            knobLayer.frame = NSRect(origin: NSPoint(x: 0, y: (bounds.height - knobWidth) * 0.5), size: NSSize(width: knobWidth, height: knobWidth))
            dotLayer.frame = knobLayer.bounds.insetBy(dx: dotBorderWidth, dy: dotBorderWidth)
        }else {
            trackLayer.frame = NSRect(origin: NSPoint(x: (bounds.width - trackHeight) * 0.5, y: 0), size: NSSize(width: trackHeight, height: bounds.height))
            tintLayer.frame = NSRect(origin: .zero, size: NSSize(width: trackLayer.frame.height, height: 0))
            knobLayer.frame = NSRect(origin: NSPoint(x: (bounds.width - knobWidth) * 0.5, y: 0), size: NSSize(width: knobWidth, height: knobWidth))
            dotLayer.frame = knobLayer.bounds.insetBy(dx: dotBorderWidth, dy: dotBorderWidth)
        }
        trackLayer.cornerRadius = trackHeight * 0.5
        tintLayer.cornerRadius = trackHeight * 0.5
        knobLayer.cornerRadius = knobWidth * 0.5
        dotLayer.cornerRadius = dotLayer.bounds.height * 0.5
    }
    private func animateHighLightedKnob(highLighted : Bool) {
        
        let dotHighLighted = knobLayer.bounds.insetBy(dx: 1, dy: 1)
        
        let dotDefault = knobLayer.bounds.insetBy(dx: dotBorderWidth, dy: dotBorderWidth)
        
        let dotBounds = CASpringAnimation(keyPath: "bounds")
        dotBounds.mass = 0.5
        dotBounds.damping = 5
        dotBounds.toValue = highLighted ? dotHighLighted : dotDefault
        
        let dotRadius = CASpringAnimation(keyPath: "cornerRadius")
        dotRadius.mass = 0.5
        dotRadius.damping = 5
        dotRadius.toValue = highLighted ? (dotHighLighted.height * 0.5) : (dotDefault.height * 0.5)
        
        let animation = CAAnimationGroup()
        animation.animations = [dotBounds,dotRadius]
        animation.duration = 0.35
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        if highLighted {
            dotLayer.add(animation, forKey: animationHighlightedKey)
        }else {
            dotLayer.add(animation, forKey: animationDeHighlightedKey)
        }
        
    }
    private func updateProgress() {
        guard maxValue != minValue else {
            return
        }
        // 使用abs是为了防止最小值和最大值赋值反了，最小值大于最大值的情况.
        let progress = abs((value - minValue) / (maxValue - minValue))
        if bounds.width > bounds.height {
            tintLayer.frame = NSRect(origin: .zero, size: NSSize(width: bounds.width * CGFloat(progress), height: trackLayer.frame.height))
            knobLayer.frame = NSRect(origin: NSPoint(x: totalWidth * CGFloat(progress), y: (bounds.height - knobWidth) * 0.5), size: NSSize(width: knobWidth, height: knobWidth))
        }else {
            tintLayer.frame = NSRect(origin: .zero, size: NSSize(width: trackLayer.frame.width, height: bounds.height * CGFloat(progress)))
            knobLayer.frame = NSRect(origin: NSPoint(x: (bounds.width - knobWidth) * 0.5, y: totalWidth * CGFloat(progress)), size: NSSize(width: knobWidth, height: knobWidth))
        }
    }
    open override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        if knobLayer.frame.contains(location) {
            touchLocation = .knob
            dragStartLocation = location
            dragStartProgress = abs((value - minValue) / (maxValue - minValue))
            animateHighLightedKnob(highLighted: true)
        }else if trackLayer.frame.contains(location) {
            touchLocation = .track
        }else {
            touchLocation = .out
        }
        valueState = .begin
    }
    open override func mouseDragged(with event: NSEvent) {
        // 只有拖动滑块才能拖拽.
        guard let startLocation = dragStartLocation,
        let startProgress = dragStartProgress else {
            return
        }
        let location = convert(event.locationInWindow, from: nil)
        // 获取x轴上面移动的距离.
        let offset = bounds.width > bounds.height ? (location.x - startLocation.x) : (location.y - startLocation.y)
        // 获取到变化的进度.
        let offProgress = offset / totalWidth
        var toPogress = CGFloat(startProgress) + offProgress
        toPogress = max(0, toPogress)
        toPogress = min(1, toPogress)
        // 得到当前的值.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // 实时更新 所以不需要隐式动画
        if let _ = optionValues {
            value = Double(Int(Double(toPogress) * abs((maxValue - minValue)) + minValue))
        }else {
            value = Double(toPogress) * abs((maxValue - minValue)) + minValue
        }
        CATransaction.commit()
        valueState = .change
        sendAction(action, to: target)
    }
    open override func mouseUp(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        var toProgress = bounds.width > bounds.height ? location.x / bounds.width : location.y / bounds.height
        toProgress = max(0, toProgress)
        toProgress = min(1, toProgress)
        if let _ = optionValues {
            value = Double(Int(Double(toProgress) * abs(maxValue - minValue) + minValue))
        }else {
            value = Double(toProgress) * abs(maxValue - minValue) + minValue
        }
        if touchLocation == .knob {
            animateHighLightedKnob(highLighted: false)
        }
        dragStartLocation = nil
        dragStartProgress = nil
        touchLocation = .out
        valueState = .end
        sendAction(action, to: target)
    }
}
