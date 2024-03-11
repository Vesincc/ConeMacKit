//
//  File.swift
//
//
//  Created by HanQi on 2023/11/2.
//

import Foundation
import Cocoa
 
public class Interactive {
     
    public struct State: OptionSet, Hashable {
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        public var rawValue: UInt
           
        public static var normal: Interactive.State {
            Interactive.State(rawValue: 1 << 0)
        }
        
        public static var selected: Interactive.State {
            Interactive.State(rawValue: 1 << 1)
        }
        
        public static var disabled: Interactive.State {
            Interactive.State(rawValue: 1 << 2)
        }
         
        public static var clicked: Interactive.State {
            Interactive.State(rawValue: 1 << 3)
        }
        
        public static var hovered: Interactive.State {
            Interactive.State(rawValue: 1 << 4)
        }
    }
    
    public enum GradientDirection {
        case horizontal
        case vertical
        case obliqueUpward
        case obliqueDescent
        
        var info: (points: (CGPoint, CGPoint), locations: [NSNumber]) {
            switch self {
            case .horizontal:
                return ((CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5)), [0, 1])
            case .vertical:
                return ((CGPoint(x: 0.5, y: 1), CGPoint(x: 0.5, y: 0)), [0, 1])
            case .obliqueUpward:
                return ((CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0)), [0, 1])
            case .obliqueDescent:
                return ((CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1)), [0, 1])
            }
        }
    }
    
    
    public enum Event {
        case mouseDown
        case mouseUpInside
        case mouseUpOutside
    }
    
}


// MARK: - InteractiveStateable

public protocol InteractiveStateable: AnyObject {
    
    var interactiveState: Interactive.State { get set }
    
    var isEnabled: Bool { get set }
    
    var isSelected: Bool { get set }
    
    /// 鼠标是否在当前控件内
    var isEntered: Bool { get set }
    
    /// 鼠标是否按下
    var isClicked: Bool { get set }
    
    
    var interactiveEventActions: [Interactive.Event : ((Any?) -> ())?] { get set }
    
     
    /// 状态改变回调
    func interactiveStateDidChanged(lastState: Interactive.State)
     
    /// 添加事件
    func setEventAction(_ action: ((Any?) -> ())?, for interactiveEvent: Interactive.Event)
}

public extension InteractiveStateable {
    
    func setEventAction(_ action: ((Any?) -> ())?, for interactiveEvent: Interactive.Event) {
        interactiveEventActions[interactiveEvent] = action
    }
    
}


public extension InteractiveStateable {
    
    func statePriority(for state: Interactive.State) -> [Interactive.State] {
        if state == [.disabled, .selected, .hovered] {
            return [[.disabled, .selected, .hovered], [.disabled, .selected], .disabled, .selected, .normal]
        } else if state == [.disabled, .selected] {
            return [[.disabled, .selected], .disabled, .selected, .normal]
        } else if state == [.disabled, .hovered] {
            return [[.disabled, .hovered], .disabled, .normal]
        } else if state == .disabled {
            return [.disabled, .normal]
        } else if state == [.selected, .clicked, .hovered] || state == [.selected, .clicked] {
            return [[.selected, .clicked, .hovered], [.selected, .clicked], [.selected, .hovered], .selected, .normal]
        } else if state == [.selected, .hovered] {
            return [[.selected, .hovered], .selected, .normal]
        } else if state == .selected {
            return [.selected, .normal]
        } else if state == [.clicked, .hovered] || state == .clicked {
            return [[.clicked, .hovered], .clicked, .hovered, .normal]
        } else if state == [.hovered] {
            return [.hovered, .normal]
        } else if state == .normal {
            return [.normal]
        } else {
            return [.normal]
        }
    }
    
    func adapterValue<T>(in dic: [Interactive.State : T], for statePriority: [Interactive.State]) -> T? {
        for i in 0 ..< statePriority.count {
            if let value = dic[statePriority[i]] {
                return value
            }
        }
        return nil
    }
    
    func adapterState(attentions: [Interactive.State]) -> Interactive.State {
        let priority = statePriority(for: interactiveState)
        return priority.first(where: { attentions.contains($0) }) ?? .normal
    }
    
    func fixState() {
        var state: Interactive.State = []
        if !isEnabled {
            state = [state, .disabled]
        }
        if isSelected {
            state = [state, .selected]
        }
        if isEntered {
            state = [state, .hovered]
        }
        if isClicked {
            state = [state, .clicked]
        }
        if state.isEmpty {
            state = .normal
        }
        let last = self.interactiveState
        self.interactiveState = state
        interactiveStateDidChanged(lastState: last)
    }
}

// MARK: - InteractiveViewProtocol

public protocol InteractiveViewProtocol: NSView, InteractiveStateable {
    
    var mouseTrackingArea: NSTrackingArea! { get set }
    
    /// 背景值是否生效
    var backgroundColorEnable: Bool { get }
    
    /// 属性值
    var interactiveBackgroundColors: [Interactive.State : NSColor] { get set }
     
    var interactiveBorderColors: [Interactive.State : NSColor] { get set }
    
    var interactiveBorderWidths: [Interactive.State : CGFloat] { get set }
    
    var interactiveCursors: [Interactive.State : NSCursor] { get set }
    
    /// 状态切换时调用block 用于扩展其他未定义属性跟随随状态改变
    var interactiveBlocks: [Interactive.State : () -> ()] { get set }
    
}

extension InteractiveViewProtocol {
    func configerTrackingArea() {
        
        mouseTrackingArea = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(mouseTrackingArea)
        
        if var mouseLocation = window?.mouseLocationOutsideOfEventStream {
            mouseLocation = convert(mouseLocation, from: nil)
            if bounds.contains(mouseLocation) {
                mouseEntered(with: NSEvent())
            } else {
                mouseExited(with: NSEvent())
            }
        }
    }
    
    func updateMouseEnterExitTrackingArea() {
        if let mouseTrackingArea = mouseTrackingArea {
            removeTrackingArea(mouseTrackingArea)
        }
        configerTrackingArea()
    }
    
    func interactiveMouseEntered(with event: NSEvent) {
        isEntered = true
        fixState()
    }
    
    func interactiveMouseExited(with event: NSEvent) {
        isEntered = false
        fixState()
    }
    
    func interactiveMouseDownPrefix(with event: NSEvent) {
        guard isEnabled else {
            return
        }
        if let action = interactiveEventActions[.mouseDown] {
            action?(self)
        }
        isClicked = true
        fixState()
    }
    
    func interactiveMouseDownSuffix(with event: NSEvent) {
        guard isEnabled else {
            return
        }
        isClicked = false
        guard let window = event.window else {
            return
        }
        let windowPoint = window.convertPoint(fromScreen: NSEvent.mouseLocation)
        if let location = superview?.convert(windowPoint, from: nil) {
            isEntered = frame.contains(location)
        }
        if isEntered {
            if let action = interactiveEventActions[.mouseUpInside] {
                action?(self)
            }
        } else {
            if let action = interactiveEventActions[.mouseUpOutside] {
                action?(self)
            }
        }
        fixState()
    }
}
 
public extension InteractiveViewProtocol {
    
    func cursor(for state: Interactive.State) -> NSCursor? {
        adapterValue(in: interactiveCursors, for: statePriority(for: state))
    }
    
    func setCursor(_ cursor: NSCursor?, for state: Interactive.State) {
        if let cursor = cursor {
            interactiveCursors[state] = cursor
            fixState()
        }
    }
    
    
    func backgroundColor(for state: Interactive.State) -> NSColor? {
        adapterValue(in: interactiveBackgroundColors, for: statePriority(for: state))
    }
    
    func setBackgroundColor(_ color: NSColor?, for state: Interactive.State) {
        if let color = color {
            interactiveBackgroundColors[state] = color
            fixState()
        }
    }
     
    func borderColor(for state: Interactive.State) -> NSColor? {
        adapterValue(in: interactiveBorderColors, for: statePriority(for: state))
    }
    
    func setBorderColor(_ color: NSColor?, for state: Interactive.State) {
        if let color = color {
            interactiveBorderColors[state] = color
            fixState()
        }
    }
    
    func borderWidth(for state: Interactive.State) -> CGFloat? {
        adapterValue(in: interactiveBorderWidths, for: statePriority(for: state))
    }
    
    func setBorderWidth(_ width: CGFloat?, for state: Interactive.State) {
        if let width = width {
            interactiveBorderWidths[state] = width
            fixState()
        }
    }
    
    func block(for state: Interactive.State) -> (() -> ())? {
        adapterValue(in: interactiveBlocks, for: statePriority(for: state))
    }
    
    func setBlock(_ block: @escaping () -> (), for state: Interactive.State) {
        interactiveBlocks[state] = block
    }
    
    
}


// MARK: - InteractiveGradientViewProtocol

public protocol InteractiveGradientViewProtocol: InteractiveViewProtocol {
    
    var interactiveColors: [Interactive.State : [NSColor]] { get set }
    
    var interactivePoints: [Interactive.State : (start: CGPoint, end: CGPoint)] { get set }
    
    var interactiveLocations: [Interactive.State : [NSNumber]] { get set }
    
}


public extension InteractiveGradientViewProtocol {
    
    func colors(for state: Interactive.State) -> [NSColor]? {
        adapterValue(in: interactiveColors, for: statePriority(for: state))
    }
    
    func setColors(_ colors: [NSColor]?, for state: Interactive.State) {
        if let colors = colors {
            interactiveColors[state] = colors
            fixState()
        }
    }
      
    
    func points(for state: Interactive.State) -> (start: CGPoint, end: CGPoint)? {
        adapterValue(in: interactivePoints, for: statePriority(for: state))
    }
    
    func setPoints(_ points: (start: CGPoint, end: CGPoint)?, for state: Interactive.State) {
        if let points = points {
            interactivePoints[state] = points
            fixState()
        }
    }
    
    
    func location(for state: Interactive.State) -> [NSNumber]? {
        adapterValue(in: interactiveLocations, for: statePriority(for: state))
    }
    
    func setLocation(_ val: [NSNumber]?, for state: Interactive.State) {
        if let val = val {
            interactiveLocations[state] = val
            fixState()
        }
    }
    
    
}



public protocol InteractiveButtonProtocol: NSButton, InteractiveViewProtocol {
    
    /// 在该状态下是否隐藏文字和图片
    var interactiveHiddenImageAndText: [Interactive.State : (imageHidden: Bool, textHidden: Bool)] { get set }
    
    var interactiveTexts: [Interactive.State : String] { get set }
    
    var interactiveTextColors: [Interactive.State : NSColor] { get set }
    
    var interactiveAttributedTexts: [Interactive.State : NSAttributedString] { get set }
    
    var interactiveImages: [Interactive.State : NSImage?] { get set }
    
    var interactiveFonts: [Interactive.State : NSFont] { get set }
    
}

public extension InteractiveButtonProtocol {
    
    func isHiddenImageAndText(for state: Interactive.State) -> (imageHidden: Bool, textHidden: Bool) {
        adapterValue(in: interactiveHiddenImageAndText, for: statePriority(for: state)) ?? (false, false)
    }
    
    func setHiddenImageAndText(_ val: (imageHidden: Bool, textHidden: Bool), for state: Interactive.State) {
        interactiveHiddenImageAndText[state] = val
        fixState()
    }
    
    func text(for state: Interactive.State) -> String? {
        adapterValue(in: interactiveTexts, for: statePriority(for: state))
    }
    
    func setText(_ text: String?, for state: Interactive.State) {
        if let text = text {
            interactiveTexts[state] = text
            fixState()
        }
    }
    
    func textColor(for state: Interactive.State) -> NSColor? {
        adapterValue(in: interactiveTextColors, for: statePriority(for: state))
    }
    
    func setTextColor(_ color: NSColor?, for state: Interactive.State) {
        if let color = color {
            interactiveTextColors[state] = color
            fixState()
        }
    }
    
    func attributedText(for state: Interactive.State) -> NSAttributedString? {
        adapterValue(in: interactiveAttributedTexts, for: statePriority(for: state))
    }
    
    func setAttributedText(_ text: NSAttributedString?, for state: Interactive.State) {
        if let text = text {
            interactiveAttributedTexts[state] = text
            fixState()
        }
    }
    
    
    func image(for state: Interactive.State) -> NSImage? {
        adapterValue(in: interactiveImages, for: statePriority(for: state)) ?? image
    }
    
    func setImage(_ image: NSImage?, for state: Interactive.State) {
        interactiveImages[state] = image
        fixState()
    }
    
    func font(for state: Interactive.State) -> NSFont {
        adapterValue(in: interactiveFonts, for: statePriority(for: state)) ?? NSFont.systemFont(ofSize: 14)
    }
    
    func setFont(_ font: NSFont, for state: Interactive.State) {
        interactiveFonts[state] = font
        fixState()
    }
    

}

 

public protocol InteractiveGradientButtonProtocol: InteractiveButtonProtocol, InteractiveGradientViewProtocol {
}
 
 
 


