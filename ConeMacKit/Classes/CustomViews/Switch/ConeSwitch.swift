//
//  COSwitch.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/9.
//

import Foundation
import Cocoa

open class ConeSwitch: NSControl {
      
    @IBInspectable open var onKnobColor: NSColor = .white {
        didSet {
            beadLayer.backgroundColor =  on ? onKnobColor.cgColor : knobColor.cgColor
        }
    }
    
    @IBInspectable open var knobColor: NSColor = .white {
        didSet {
            beadLayer.backgroundColor =  on ? onKnobColor.cgColor : knobColor.cgColor
        }
    }
    
    @IBInspectable open var tintColor: NSColor = NSColor(rgb: 0x444444) {
        didSet {
            layer?.backgroundColor = on ? onTintColor.cgColor : tintColor.cgColor
        }
    }
    
    @IBInspectable open var onTintColor: NSColor = NSColor(rgb: 0x2AC081) {
        didSet {
            layer?.backgroundColor = on ? onTintColor.cgColor : tintColor.cgColor
        }
    }
    
    @IBInspectable open var highLightedAnimationEnable: Bool = true
    
    
    private let animationMoveKey = "animation.bead.move"
    
    private let animationBackgroundKey = "animation.bead.background"

    private var beadLayer = CALayer()
      
    public var edgeInsects = NSEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
    
    private var isDrag = false
    // 是否点击滑块
    private var mousedownLocationInBead : NSPoint?

    open func setOn(_ on: Bool, animated : Bool) {
        self.on = on
        layer?.backgroundColor = on ? onTintColor.cgColor : tintColor.cgColor
        beadLayer.backgroundColor =  on ? onKnobColor.cgColor : knobColor.cgColor

        updateOnState(animated: animated)
    }

    /// default with animated.
    public var isOn : Bool {
        return on
    }
        
    private var on : Bool = false
    
    var beadWidth : CGFloat {
        return bounds.height - edgeInsects.top - edgeInsects.bottom
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initial()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initial()
    }
    
    private func initial() {
        isEnabled = true
        wantsLayer = true

        layer?.borderColor = onTintColor.cgColor
        layer?.cornerRadius = bounds.height * 0.5
        
        beadLayer.bounds = CGRect(origin: .zero, size: NSSize(width: beadWidth, height: beadWidth))
        beadLayer.cornerRadius = beadLayer.bounds.height * 0.5
        layer?.addSublayer(beadLayer)
        
        updateOnState()
        
        setOn(on, animated: false)
    }
     
    
    open override var frame: NSRect {
        didSet {
            layer?.cornerRadius = bounds.height * 0.5
            beadLayer.bounds = CGRect(origin:.zero, size: NSSize(width: bounds.height - edgeInsects.top - edgeInsects.bottom, height: bounds.height - edgeInsects.top - edgeInsects.bottom))
            beadLayer.cornerRadius = beadLayer.bounds.height * 0.5
        }
    }
    
    private func updateOnState(animated : Bool = false) {
        let width = (bounds.height - edgeInsects.top - edgeInsects.bottom)
        /*
         off: edgeInsects.left + width * 0.5
         on: bounds.width - edgeInsects.right - width * 0.5
         **/
        let x = on ? (bounds.width - edgeInsects.right - width * 0.5) : (edgeInsects.left + width * 0.5)
        if !animated {
            beadLayer.position = NSPoint(x: x, y: bounds.midY)
            return
        }
        let animation = CASpringAnimation(keyPath: "position.x")
        animation.duration = 0.5
        animation.mass = 0.5
        animation.damping = 5
        animation.toValue = x
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        beadLayer.add(animation, forKey: animationMoveKey)
    }
    
    private func highLightedBead(highLighted : Bool) {
        if highLightedAnimationEnable {
            let animation = CASpringAnimation(keyPath: "transform.scale")
            animation.duration = 0.35
            animation.mass = 0.5
            animation.damping = 5
            if highLighted {
                animation.toValue = 1.1
            }else {
                animation.toValue = 1
            }
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            beadLayer.add(animation, forKey: nil)
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if !isEnabled {
            return
        }
        guard let locationInLayer = layer?.convert(event.locationInWindow, from: nil) else {
            return
        }
        highLightedBead(highLighted: true)
        if beadLayer.frame.contains(locationInLayer) {
            // 点击滚珠
            mousedownLocationInBead = locationInLayer
        }
    }
    
    public override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        if mousedownLocationInBead == nil {
            return
        }
        guard let locationInLayer = layer?.convert(event.locationInWindow, from: nil) else {
            return
        }
        if abs(mousedownLocationInBead!.x - locationInLayer.x) > beadLayer.frame.width * 0.5 {
            // 拖拽距离足够认为是拖动
            isDrag = true
        }
        var beadPosition = beadLayer.position
        beadPosition.x = locationInLayer.x
        let width = beadWidth
        /*
         off: edgeInsects.left + width * 0.5
         on: bounds.width - edgeInsects.right - width * 0.5
         **/
        let off = edgeInsects.left + width * 0.5
        let on = bounds.width - edgeInsects.right - width * 0.5
        if beadPosition.x < off {
            beadPosition.x = off
        }else if beadPosition.x > on {
            beadPosition.x = on
        }
        beadLayer.position = beadPosition
    }
    
    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        defer {
            // 重置拖动记录相关
            mousedownLocationInBead = nil
            isDrag = false
        }
        if !isEnabled {
            return
        }
        var x : CGFloat = 0
        let width = beadWidth
        let off = edgeInsects.left + width * 0.5
        let on = bounds.width - edgeInsects.right - width * 0.5
        if isDrag {
            x = beadLayer.position.x
            if x < (on - off) * 0.5 + off {
                x = off
            }else {
                x = on
            }
        }else {
            guard let _ = layer?.convert(event.locationInWindow, from: nil) else {
                // 点击非layer区域.
                return
            }
            // 反向
            x = self.on ? off : on
        }
        var shouldSendAction = false
        
        let t_isOn = x == off ? false : true
        if t_isOn != self.isOn {
            shouldSendAction = true
        }
        // 根据需要恢复或者反向动画到边远位置.
        setOn(t_isOn, animated: true)
        if shouldSendAction {
            sendAction(action, to: target)
        }
        highLightedBead(highLighted: false)
    }
}

extension ConeSwitch : CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if beadLayer.animation(forKey: animationMoveKey) == anim {
            var position = beadLayer.position
            position.x = CGFloat((anim as! CABasicAnimation).toValue as! Double)
            beadLayer.position = position
            beadLayer.removeAnimation(forKey: animationMoveKey)
        }
        if beadLayer.animation(forKey: animationBackgroundKey) == anim {
            let background = ((anim as! CABasicAnimation).toValue as! CGColor)
            beadLayer.backgroundColor = background
            beadLayer.removeAnimation(forKey: animationBackgroundKey)
        }
    }
}
