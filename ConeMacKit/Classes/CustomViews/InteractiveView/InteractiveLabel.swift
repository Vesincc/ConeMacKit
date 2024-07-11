//
//  InteractiveLabel.swift
//
//
//  Created by HanQi on 2023/11/7.
//

import Cocoa

public extension InteractiveLabel {
    
    func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange, for state: Interactive.State) {
        if let attrs = attrs {
            let item = interactiveItem(at: range)
            item.interactiveAttributes[state] = attrs
            item.setNeedApply()
            item.fixState()
        }
        updateAttributesIfNeed()
    }
    
    func setBlock(_ block: @escaping () -> (), range: NSRange, for state: Interactive.State) {
        let item = interactiveItem(at: range)
        item.interactiveBlocks[state] = block
        item.fixState()
        updateAttributesIfNeed()
    }
     
    func setEventAction(_ action: ((_ range: NSRange) -> ())?, for interactiveEvent: Interactive.Event, range: NSRange) {
        let item = interactiveItem(at: range)
        item.setEventAction({ range in
            action?(range as? NSRange ?? NSRange(location: 0, length: 0))
        }, for: interactiveEvent)
        item.fixState()
        updateAttributesIfNeed()
    }
    
    func setCursor(_ cursor: NSCursor, range: NSRange, for state: Interactive.State) {
        let item = interactiveItem(at: range)
        item.interactiveCursors[state] = cursor
        item.setNeedApply()
        item.fixState()
        updateAttributesIfNeed()
    }
    
}

public extension InteractiveLabel {
    
    override var attributedStringValue: NSAttributedString {
        didSet {
            originAttributedStringValue = attributedStringValue
        }
    }
    
    override var stringValue: String {
        didSet {
            originAttributedStringValue = NSAttributedString(string: stringValue, attributes: [
                .font : font ?? NSFont.systemFont(ofSize: 14),
                .foregroundColor : textColor ?? NSColor.white
            ])
        }
    }
    
}

open class InteractiveLabel: NSTextField {
     
    
    class InteractiveItem: InteractiveStateable, Equatable {
        
        public var interactiveEventActions: [Interactive.Event : ((Any?) -> ())?] = [:]
        
        static func == (lhs: InteractiveLabel.InteractiveItem, rhs: InteractiveLabel.InteractiveItem) -> Bool {
            lhs.uuid == rhs.uuid
        }
        
        
        internal init(range: NSRange, isEnabled: Bool, isSelected: Bool) {
            self.range = range
            self.isEnabled = isEnabled
            self.isSelected = isSelected
        }
        
        var uuid = UUID()
        
        var interactiveState: Interactive.State = .normal
        
        var isEnabled: Bool = true
        
        var isSelected: Bool = false
        
        var isEntered: Bool = false
        
        var isClicked: Bool = false
        
        var interactiveAttributes: [Interactive.State : [NSAttributedString.Key : Any]] = [:]
        
        var interactiveBlocks: [Interactive.State : () -> ()] = [:]
        
        var interactiveCursors: [Interactive.State : NSCursor] = [:]
        
        
        var rects: [CGRect] = []
        
        let range: NSRange
        
        var isNeedApply = true
        
        func setNeedApply() {
            isNeedApply = true
        }
        
        func interactiveStateDidChanged(lastState: Interactive.State) {
            if lastState != interactiveState {
                setNeedApply()
            }
            let priority = statePriority(for: interactiveState)
            let block = adapterValue(in: interactiveBlocks, for: priority)
            block?()
        }
        
        
        func applyIfNeed(in str: NSMutableAttributedString) {
            guard isNeedApply else {
                return
            }
            isNeedApply = false
            guard range.location >= 0 && (range.location + range.length) <= str.length else {
                return
            }
            if let attributes = adapterValue(in: interactiveAttributes, for: statePriority(for: interactiveState)) {
                str.setAttributes(attributes, range: range)
            }
        }
         
        var cursorInfo: (rects: [CGRect], cursor: NSCursor)? {
            if let cursor = adapterValue(in: interactiveCursors, for: statePriority(for: interactiveState)) {
                return (rects, cursor)
            }
            return nil
        }
        
        func moved(at item: InteractiveItem?) {
            isEntered = item == self
            fixState()
        }
        
        func mouseDown(at item: InteractiveItem?) {
            if item == self {
                isClicked = true
                if let action = interactiveEventActions[.mouseDown] {
                    action?(range)
                }
            } else {
                isClicked = false
            }
            fixState()
        }
        
        func mouseUp(at item: InteractiveItem?) {
            isClicked = false
            isEntered = item == self
            if isEntered {
                if let action = interactiveEventActions[.mouseUpInside] {
                    action?(range)
                }
            } else {
                if let action = interactiveEventActions[.mouseUpOutside] {
                    action?(range)
                }
            }
            fixState()
        }
        
    }
    
    lazy var originAttributedStringValue: NSAttributedString = NSAttributedString(string: stringValue, attributes: [
        .font : font ?? NSFont.systemFont(ofSize: 14),
        .foregroundColor : textColor ?? NSColor.white
    ])
    
    
    var _isEnabled: Bool = true
    open override var isEnabled: Bool {
        get {
            _isEnabled
        }
        set {
            _isEnabled = newValue
            items.forEach({
                $0.isEnabled = _isEnabled
                $0.fixState()
            })
            updateAttributesIfNeed()
        }
    }
    
    open var isSelected: Bool = false {
        didSet {
            items.forEach({
                $0.isSelected = isSelected
                $0.fixState()
            })
            updateAttributesIfNeed()
        }
    }
    
    public var cursor: NSCursor? = nil {
        didSet {
            window?.invalidateCursorRects(for: self)
        }
    }
    
    /// 移动防抖
    public var antiShakeEnable = true
    
    /// 绘制文本边框
    public var drawTextBorder = false
    
    var items: [InteractiveItem] = []
    
    public var mouseTrackingArea: NSTrackingArea!
    
    private var moveEvent: NSEvent?
    
    func configerTrackingArea() {
        mouseTrackingArea = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
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
    
    open override func resetCursorRects() {
        if let cursor = cursor {
            addCursorRect(bounds, cursor: cursor)
        }
        items.forEach { item in
            if let info = item.cursorInfo {
                info.rects.forEach({
                    addCursorRect($0, cursor: info.cursor)
                })
            }
        }
    }
    
    func updateMouseEnterExitTrackingArea() {
        if let mouseTrackingArea = mouseTrackingArea {
            removeTrackingArea(mouseTrackingArea)
        }
        configerTrackingArea()
    }
    
    open override func mouseEntered(with event: NSEvent) {
        mouseMoved(with: event)
    }
    
    open override func mouseExited(with event: NSEvent) {
        mouseMoved(with: event)
    }
    
    open override func mouseDragged(with event: NSEvent) {
        mouseMoved(with: event)
    }
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        updateMouseEnterExitTrackingArea()
    }
    
    open override func mouseDown(with event: NSEvent) {
        guard isEnabled else {
            return
        }
        let item = focuseItem(at: event)
        items.forEach({ $0.mouseDown(at: item) })
        updateAttributesIfNeed()
    }
    
    open override func mouseUp(with event: NSEvent) {
        guard isEnabled else {
            return
        }
        let item = focuseItem(at: event)
        items.forEach({ $0.mouseUp(at: item) })
        updateAttributesIfNeed()
    }
    
    open override func mouseMoved(with event: NSEvent) {
        if let moveEvent = moveEvent {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(movedShake(with:)), object: moveEvent)
        }
        if let _ = focuseItem(at: event) {
            moveEvent = event
            self.perform(#selector(movedShake(with:)), with: event, afterDelay: antiShakeEnable ? 0.02 : 0)
        } else {
            moveEvent = nil
            self.perform(#selector(movedShake(with:)), with: event, afterDelay: 0)
        }
    }
    
    @objc func movedShake(with event: NSEvent) {
        let item = focuseItem(at: event)
        items.forEach({ $0.moved(at: item) })
        updateAttributesIfNeed()
    }
    
    
    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateItemsRects(drawEnable: drawTextBorder)
    }
    
}

private extension InteractiveLabel {
    
    func interactiveItem(at range: NSRange) -> InteractiveItem {
        if let first = items.first(where: { $0.range == range }) {
            return first
        }
        let item = InteractiveItem(range: range, isEnabled: isEnabled, isSelected: isSelected)
        items.append(item)
        return item
    }
    
    func focuseItem(at event: NSEvent) -> InteractiveItem? {
        let point = convert(event.locationInWindow, from: nil)
        guard bounds.contains(point) else {
            return nil
        }
        return items.first(where: { item in
            item.rects.contains(where: { $0.contains(point) })
        })
    }
    
    func updateAttributesIfNeed() {
        if items.contains(where: { $0.isNeedApply }) {
            let attributedString = originAttributedStringValue.mutableCopy() as! NSMutableAttributedString
            items.forEach({
                $0.setNeedApply()
                $0.applyIfNeed(in: attributedString)
            })
            let origin = originAttributedStringValue
            attributedStringValue = attributedString
            originAttributedStringValue = origin
            
            updateItemsRects()
            window?.invalidateCursorRects(for: self)
        }
    }
    
    func updateItemsRects(drawEnable: Bool = false) {
        let context = NSGraphicsContext.current?.cgContext
        
        let attributedString = attributedStringValue
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: bounds.height + 4))
        textContainer.lineFragmentPadding = 2
        if let paragraphStyle = attributedString.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle {
            if paragraphStyle.alignment == .center {
                textContainer.lineFragmentPadding = 4
            }
        }
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        var linesInfo: [(rect: CGRect, range: NSRange)] = []
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs)) { rect, usedRect, textContainer, glyphRange, stop in
            linesInfo.append((usedRect, glyphRange))
        }
        var lineOffset: CGFloat = 0
        if linesInfo.count > 1 {
            lineOffset = (bounds.size.height - linesInfo.map({ $0.rect.size.height }).reduce(0, +)) / CGFloat(linesInfo.count - 1)
        }
        linesInfo = linesInfo.enumerated().map({
            let rect = CGRect(origin: CGPoint(x: $0.element.rect.origin.x, y: $0.element.rect.origin.y + lineOffset * CGFloat($0.offset)), size: $0.element.rect.size)
            if drawEnable, self.drawTextBorder {
                context?.setLineWidth(1)
                context?.setStrokeColor(NSColor.cyan.cgColor)
                context?.addRect(rect)
                context?.stroke(rect)
            }
            return (rect, $0.element.range)
        })
        
        items.forEach({ $0.rects.removeAll() })
        linesInfo.forEach { line in
            items.forEach { item in
                let itemRange = item.range
                let intersectionRange = NSIntersectionRange(line.range, itemRange)
                if intersectionRange.length > 0 {
                    let intersectionRect = layoutManager.boundingRect(forGlyphRange: intersectionRange, in: textContainer)
                    item.rects.append(CGRect(x: intersectionRect.minX, y: line.rect.minY, width: intersectionRect.width, height: line.rect.height))
                }
            }
        }
        if drawEnable, drawTextBorder {
            items.forEach({ item in
                context?.setStrokeColor(NSColor.red.cgColor)
                item.rects.forEach({
                    context?.addRect($0)
                    context?.stroke($0)
                })
            })
        }
    }
     
}


//import CoreText
//
//
//public extension InteractiveLabel {
//
//    func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange, for state: Interactive.State) {
//        if let attrs = attrs {
//            let item = interactiveItem(at: range)
//            item.interactiveAttributes[state] = attrs
//            item.setNeedApply()
//            item.fixState()
//        }
//        updateAttributesIfNeed()
//    }
//
//    func setBlock(_ block: @escaping () -> (), range: NSRange, for state: Interactive.State) {
//        let item = interactiveItem(at: range)
//        item.interactiveBlocks[state] = block
//        item.fixState()
//        updateAttributesIfNeed()
//    }
//
//    func setEventAction(_ action: ((_ range: NSRange) -> ())?, for interactiveEvent: Interactive.Event, range: NSRange) {
//        let item = interactiveItem(at: range)
//        item.setEventAction({ range in
//            action?(range as? NSRange ?? NSRange(location: 0, length: 0))
//        }, for: interactiveEvent)
//        item.fixState()
//        updateAttributesIfNeed()
//    }
//
//    func setCursor(_ cursor: NSCursor, range: NSRange, for state: Interactive.State) {
//        let item = interactiveItem(at: range)
//        item.interactiveCursors[state] = cursor
//        item.setNeedApply()
//        item.fixState()
//        updateAttributesIfNeed()
//    }
//
//}
//
//public extension InteractiveLabel {
//
//    override var attributedStringValue: NSAttributedString {
//        didSet {
//            originAttributedStringValue = attributedStringValue
//        }
//    }
//
//    override var stringValue: String {
//        didSet {
//            originAttributedStringValue = NSAttributedString(string: stringValue, attributes: [
//                .font : font ?? NSFont.systemFont(ofSize: 14),
//                .foregroundColor : textColor ?? NSColor.white
//            ])
//        }
//    }
//
//}
//
//open class InteractiveLabel: NSTextField {
//
//
//    class InteractiveItem: InteractiveStateable, Equatable {
//
//        public var interactiveEventActions: [Interactive.Event : ((Any?) -> ())?] = [:]
//
//        static func == (lhs: InteractiveLabel.InteractiveItem, rhs: InteractiveLabel.InteractiveItem) -> Bool {
//            lhs.uuid == rhs.uuid
//        }
//
//
//        internal init(range: NSRange, isEnabled: Bool, isSelected: Bool) {
//            self.range = range
//            self.isEnabled = isEnabled
//            self.isSelected = isSelected
//        }
//
//        var uuid = UUID()
//
//        var interactiveState: Interactive.State = .normal
//
//        var isEnabled: Bool = true
//
//        var isSelected: Bool = false
//
//        var isEntered: Bool = false
//
//        var isClicked: Bool = false
//
//        var interactiveAttributes: [Interactive.State : [NSAttributedString.Key : Any]] = [:]
//
//        var interactiveBlocks: [Interactive.State : () -> ()] = [:]
//
//        var interactiveCursors: [Interactive.State : NSCursor] = [:]
//
//
//        var rects: [CGRect] = []
//
//        let range: NSRange
//
//        var isNeedApply = true
//
//        func setNeedApply() {
//            isNeedApply = true
//        }
//
//        func interactiveStateDidChanged(lastState: Interactive.State) {
//            if lastState != interactiveState {
//                setNeedApply()
//            }
//            let priority = statePriority(for: interactiveState)
//            let block = adapterValue(in: interactiveBlocks, for: priority)
//            block?()
//        }
//
//
//        func applyIfNeed(in str: NSMutableAttributedString) {
//            guard isNeedApply else {
//                return
//            }
//            isNeedApply = false
//            guard range.location > 0 && (range.location + range.length) <= str.length else {
//                return
//            }
//            if let attributes = adapterValue(in: interactiveAttributes, for: statePriority(for: interactiveState)) {
//                str.setAttributes(attributes, range: range)
//            }
//        }
//
//        var cursorInfo: (rects: [CGRect], cursor: NSCursor)? {
//            if let cursor = adapterValue(in: interactiveCursors, for: statePriority(for: interactiveState)) {
//                return (rects, cursor)
//            }
//            return nil
//        }
//
//        func moved(at item: InteractiveItem?) {
//            isEntered = item == self
//            fixState()
//        }
//
//        func mouseDown(at item: InteractiveItem?) {
//            if item == self {
//                isClicked = true
//                if let action = interactiveEventActions[.mouseDown] {
//                    action?(range)
//                }
//            } else {
//                isClicked = false
//            }
//            fixState()
//        }
//
//        func mouseUp(at item: InteractiveItem?) {
//            isClicked = false
//            isEntered = item == self
//            if isEntered {
//                if let action = interactiveEventActions[.mouseUpInside] {
//                    action?(range)
//                }
//            } else {
//                if let action = interactiveEventActions[.mouseUpOutside] {
//                    action?(range)
//                }
//            }
//            fixState()
//        }
//
//    }
//
//    lazy var originAttributedStringValue: NSAttributedString = NSAttributedString(string: stringValue, attributes: [
//        .font : font ?? NSFont.systemFont(ofSize: 14),
//        .foregroundColor : textColor ?? NSColor.white
//    ])
//
//
//    var _isEnabled: Bool = true
//    open override var isEnabled: Bool {
//        get {
//            _isEnabled
//        }
//        set {
//            _isEnabled = newValue
//            items.forEach({
//                $0.isEnabled = _isEnabled
//                $0.fixState()
//            })
//            updateAttributesIfNeed()
//        }
//    }
//
//    open var isSelected: Bool = false {
//        didSet {
//            items.forEach({
//                $0.isSelected = isSelected
//                $0.fixState()
//            })
//            updateAttributesIfNeed()
//        }
//    }
//
//    public var cursor: NSCursor? = nil {
//        didSet {
//            window?.invalidateCursorRects(for: self)
//        }
//    }
//
//    /// 移动防抖
//    public var antiShakeEnable = true
//
//    /// 绘制文本边框
//    public var drawTextBorder = false
//
//    var items: [InteractiveItem] = []
//
//    public var mouseTrackingArea: NSTrackingArea!
//
//    private var moveEvent: NSEvent?
//
//    func configerTrackingArea() {
//        mouseTrackingArea = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
//        addTrackingArea(mouseTrackingArea)
//
//        if var mouseLocation = window?.mouseLocationOutsideOfEventStream {
//            mouseLocation = convert(mouseLocation, from: nil)
//            if bounds.contains(mouseLocation) {
//                mouseEntered(with: NSEvent())
//            } else {
//                mouseExited(with: NSEvent())
//            }
//        }
//    }
//
//    open override func resetCursorRects() {
//        if let cursor = cursor {
//            addCursorRect(bounds, cursor: cursor)
//        }
//        items.forEach { item in
//            if let info = item.cursorInfo {
//                info.rects.forEach({
//                    let flipped = CGRect(origin: CGPoint(x: $0.origin.x, y: bounds.size.height - $0.origin.y - $0.size.height), size: $0.size)
//                    addCursorRect(flipped, cursor: info.cursor)
//                })
//            }
//        }
//    }
//
//    func updateMouseEnterExitTrackingArea() {
//        if let mouseTrackingArea = mouseTrackingArea {
//            removeTrackingArea(mouseTrackingArea)
//        }
//        configerTrackingArea()
//    }
//
//    open override func mouseEntered(with event: NSEvent) {
//        mouseMoved(with: event)
//    }
//
//    open override func mouseExited(with event: NSEvent) {
//        mouseMoved(with: event)
//    }
//
//    open override func mouseDragged(with event: NSEvent) {
//        mouseMoved(with: event)
//    }
//
//    open override func updateTrackingAreas() {
//        print(#function)
//        super.updateTrackingAreas()
//        updateMouseEnterExitTrackingArea()
//    }
//
//    open override func mouseDown(with event: NSEvent) {
//        guard isEnabled else {
//            return
//        }
//        let item = focuseItem(at: event)
//        items.forEach({ $0.mouseDown(at: item) })
//        updateAttributesIfNeed()
//    }
//
//    open override func mouseUp(with event: NSEvent) {
//        guard isEnabled else {
//            return
//        }
//        let item = focuseItem(at: event)
//        items.forEach({ $0.mouseUp(at: item) })
//        updateAttributesIfNeed()
//    }
//
//    open override func mouseMoved(with event: NSEvent) {
//        if let moveEvent = moveEvent {
//            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(movedShake(with:)), object: moveEvent)
//        }
//        if let _ = focuseItem(at: event) {
//            moveEvent = event
//            self.perform(#selector(movedShake(with:)), with: event, afterDelay: antiShakeEnable ? 0.02 : 0)
//        } else {
//            moveEvent = nil
//            self.perform(#selector(movedShake(with:)), with: event, afterDelay: 0)
//        }
//    }
//
//    @objc func movedShake(with event: NSEvent) {
//        let item = focuseItem(at: event)
//        items.forEach({ $0.moved(at: item) })
//        updateAttributesIfNeed()
//    }
//
//
//    open override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//        updateItemsRects(drawEnable: drawTextBorder)
//    }
//
//}
//
//private extension InteractiveLabel {
//
//    func interactiveItem(at range: NSRange) -> InteractiveItem {
//        if let first = items.first(where: { $0.range == range }) {
//            return first
//        }
//        let item = InteractiveItem(range: range, isEnabled: isEnabled, isSelected: isSelected)
//        items.append(item)
//        return item
//    }
//
//    func focuseItem(at event: NSEvent) -> InteractiveItem? {
//        var point = convert(event.locationInWindow, from: nil)
//        guard bounds.contains(point) else {
//            return nil
//        }
//        point.y = bounds.maxY - point.y
//        return items.first(where: { item in
//            item.rects.contains(where: { $0.contains(point) })
//        })
//    }
//
//    func updateAttributesIfNeed() {
//        if items.contains(where: { $0.isNeedApply }) {
//            let attributedString = originAttributedStringValue.mutableCopy() as! NSMutableAttributedString
//            items.forEach({ $0.applyIfNeed(in: attributedString) })
//            let origin = originAttributedStringValue
//            attributedStringValue = attributedString
//            originAttributedStringValue = origin
//
//            updateItemsRects()
//            window?.invalidateCursorRects(for: self)
//        }
//    }
//
//    func updateItemsRects(drawEnable: Bool = false) {
//
//        items.forEach({ $0.rects.removeAll() })
//        let targetRect = CGRect(origin: .zero, size: CGSize(width: bounds.width - 4, height: bounds.height))
//        let context = NSGraphicsContext.current?.cgContext
//        context?.textMatrix = CGAffineTransform.identity
//        context?.translateBy(x: 0, y: bounds.height)
//        context?.scaleBy(x: 1, y: -1)
//        let mutableAttributedString = attributedStringValue.mutableCopy() as! NSMutableAttributedString
//        loadAttachmentsSizeCallback(mutableAttributedString: mutableAttributedString)
//        let cfAttributedString = mutableAttributedString as CFMutableAttributedString
//        let ctFramesetter = CTFramesetterCreateWithAttributedString(cfAttributedString)
//        let path = CGPath(rect: targetRect, transform: nil)
//        let ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRange(location: 0, length: attributedStringValue.length), path, nil)
//        let lines = CTFrameGetLines(ctFrame) as! [CTLine]
//        var origins: [CGPoint] = .init(repeating: .zero, count: lines.count)
//        CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: 0), &origins)
//
//        for i in 0 ..< lines.count {
//            let line = lines[i]
//            let origin = origins[i]
//            let lineBounds = calculateLineBounds(line: line, origin: origin, lineIndex: i)
//            calculateStringRectForStringIndex(line: line, lineBounds: lineBounds, items: items)
//
//            if drawEnable, drawTextBorder {
//                context?.setLineWidth(1)
//                context?.setStrokeColor(NSColor.cyan.cgColor)
//                context?.addRect(lineBounds)
//                context?.stroke(lineBounds)
//            }
//        }
//
//        if drawEnable, drawTextBorder {
//            items.forEach({ item in
//                context?.setStrokeColor(NSColor.red.cgColor)
//                item.rects.forEach({
//                    context?.addRect($0)
//                    context?.stroke($0)
//                })
//            })
//        }
//    }
//
//    struct ImageRunStruct {
//        let ascent: CGFloat
//        let descent: CGFloat
//        let width: CGFloat
//    }
//
//
//    func loadAttachmentsSizeCallback(mutableAttributedString: NSMutableAttributedString) {
//        var attachmentsRangs: [NSRange] = []
//        for i in 0 ..< mutableAttributedString.length {
//            if mutableAttributedString.containsAttachments(in: NSRange(location: i, length: 1)) {
//                attachmentsRangs.append(NSRange(location: i, length: 1))
//            }
//        }
//
//        attachmentsRangs.forEach { range in
//            let att = mutableAttributedString.attributedSubstring(from: range)
//            let size = att.boundingRect(with: .zero)
//            let extentBuffer = UnsafeMutablePointer<ImageRunStruct>.allocate(capacity: 1)
//            extentBuffer.initialize(to: ImageRunStruct(ascent: size.height, descent: 0, width: size.width))
//            var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (pointer) in
//            }, getAscent: { (pointer) -> CGFloat in
//                let d = pointer.assumingMemoryBound(to: ImageRunStruct.self)
//                return d.pointee.ascent
//            }, getDescent: { (pointer) -> CGFloat in
//                let d = pointer.assumingMemoryBound(to: ImageRunStruct.self)
//                return d.pointee.descent
//            }, getWidth: { (pointer) -> CGFloat in
//                let d = pointer.assumingMemoryBound(to: ImageRunStruct.self)
//                return d.pointee.width
//            })
//            let delegate = CTRunDelegateCreate(&callbacks, extentBuffer)
//            let attrDictionaryDelegate = [(kCTRunDelegateAttributeName as NSAttributedString.Key): (delegate as Any)]
//            mutableAttributedString.setAttributes(attrDictionaryDelegate, range: range)
//        }
//    }
//
//    func calculateLineBounds(line: CTLine, origin: CGPoint, lineIndex i: Int) -> CGRect {
//        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
//
//        var imageWidths: [CGFloat] = []
//        var lineBottom: CGFloat = 0
//        for j in 0 ..< runs.count {
//            let run = runs[j]
//            let attributes = CTRunGetAttributes(run)
//            if let runDelegate = (attributes as Dictionary)[kCTRunDelegateAttributeName] {
//                let res = CTRunDelegateGetRefCon(runDelegate as! CTRunDelegate)
//                let callBack = res.assumingMemoryBound(to: ImageRunStruct.self).pointee
//                let imageSize = CGSize(width: callBack.width, height: callBack.ascent)
//                imageWidths.append(imageSize.width)
//            } else {
//                imageWidths.append(0)
//            }
//            let runBounds = CTRunGetImageBounds(run, nil, CFRange(location: 0, length: 0))
//            lineBottom = max(abs(runBounds.origin.y), lineBottom)
//        }
//
//        var imageOffset: CGFloat = 0
//        if !imageWidths.contains(0), imageWidths.count == 1 {
//            imageOffset = 0
//        } else if imageWidths.contains(0) {
//            for j in 0 ..< imageWidths.count {
//                if imageWidths[j] == 0 {
//                    break
//                } else {
//                    imageOffset += imageWidths[j]
//                }
//            }
//        } else {
//            imageOffset += imageWidths.first ?? 0
//        }
//
//
//        var lineAscent: CGFloat = 0
//        var lineDescent: CGFloat = 0
//        var lineLeading: CGFloat = 0
//
//        let lineWidth = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading)
//        let lineHeight = lineAscent + lineLeading + lineBottom
//
//        var lineBounds = CTLineGetImageBounds(line, nil)
//        lineBounds.origin.x += origin.x - imageOffset
//        lineBounds.origin.y += origin.y  - CGFloat(1 * i)
//
//        lineBounds.origin.x = lineBounds.origin.x
//        lineBounds.origin.y = lineBounds.origin.y
//        lineBounds.size.width = lineWidth
//        lineBounds.size.height = lineHeight
//
//
//        return lineBounds
//    }
//
//    func calculateStringRectForStringIndex(line: CTLine, lineBounds: CGRect, items: [InteractiveItem]) {
//        let cfRange = CTLineGetStringRange(line)
//        let lineRange = NSRange(location: cfRange.location, length: cfRange.length)
//        for item in items {
//            let itemRange = item.range
//            let intersectionRange = NSIntersectionRange(lineRange, itemRange)
//            if intersectionRange.length > 0 {
//                let start = intersectionRange.location
//                let end = intersectionRange.location + intersectionRange.length
//                var startOffset: CGFloat = 0
//                var endOffset: CGFloat = 0
//                CTLineGetOffsetForStringIndex(line, start, &startOffset)
//                CTLineGetOffsetForStringIndex(line, end, &endOffset)
//                item.rects.append(CGRect(x: lineBounds.origin.x + startOffset, y: lineBounds.origin.y, width: lineBounds.origin.x + endOffset - startOffset, height: lineBounds.height))
//            }
//        }
//    }
//
//}
//
//



//public extension InteractiveLabel {
//
//    func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange, for state: Interactive.State) {
//        if let attrs = attrs {
//            let item = interactiveItem(at: range)
//            item.interactiveAttributes[state] = attrs
//            item.setNeedApply()
//            item.fixState()
//            updateAttributesIfNeed()
//        }
//    }
//
//    func setBlock(_ block: @escaping () -> (), range: NSRange, for state: Interactive.State) {
//        let item = interactiveItem(at: range)
//        item.interactiveBlocks[state] = block
//        item.fixState()
//    }
//
//    func setEventAction(_ action: ((Any?) -> ())?, for interactiveEvent: Interactive.Event, range: NSRange) {
//        let item = interactiveItem(at: range)
//        item.setEventAction(action, for: interactiveEvent)
//        item.fixState()
//    }
//
//}
//
//open class InteractiveLabel: NSTextField {
//
//
//    class InteractiveItem: InteractiveStateable, Equatable {
//
//        public var interactiveEventActions: [Interactive.Event : ((Any?) -> ())?] = [:]
//
//        static func == (lhs: InteractiveLabel.InteractiveItem, rhs: InteractiveLabel.InteractiveItem) -> Bool {
//            lhs.uuid == rhs.uuid
//        }
//
//
//        internal init(range: NSRange, isEnabled: Bool, isSelected: Bool) {
//            self.range = range
//            self.isEnabled = isEnabled
//            self.isSelected = isSelected
//        }
//
//        var uuid = UUID()
//
//        var interactiveState: Interactive.State = .normal
//
//        var isEnabled: Bool = true
//
//        var isSelected: Bool = false
//
//        var isEntered: Bool = false
//
//        var isClicked: Bool = false
//
//        var interactiveAttributes: [Interactive.State : [NSAttributedString.Key : Any]] = [:]
//
//        var interactiveBlocks: [Interactive.State : () -> ()] = [:]
//
//
//
//        let range: NSRange
//
//        var isNeedApply = true
//
//        func setNeedApply() {
//            isNeedApply = true
//        }
//
//        func interactiveStateDidChanged(lastState: Interactive.State) {
//            if lastState != interactiveState {
//                setNeedApply()
//            }
//            let priority = statePriority(for: interactiveState)
//            let block = adapterValue(in: interactiveBlocks, for: priority)
//            block?()
//        }
//
//
//        func applyIfNeed(in str: NSMutableAttributedString) {
//            guard isNeedApply else {
//                return
//            }
//            isNeedApply = false
//            guard range.location > 0 || (range.location + range.length) <= str.length else {
//                return
//            }
//            if let attributes = adapterValue(in: interactiveAttributes, for: statePriority(for: interactiveState)) {
//                str.setAttributes(attributes, range: range)
//            }
//        }
//
//
//        func isFocus(at index: Int?) -> Bool {
//            if let index = index {
//                if range.location <= index, (range.location + range.length) > index {
//                    return true
//                }
//            }
//            return false
//        }
//
//
//        func moved(at index: Int?) {
//            isEntered = isFocus(at: index)
//            fixState()
//        }
//
//        func mouseDown(at index: Int?) {
//            if isFocus(at: index) {
//                isClicked = true
//                if let action = interactiveEventActions[.mouseDown] {
//                    action?(range)
//                }
//            } else {
//                isClicked = false
//            }
//            fixState()
//        }
//
//        func mouseUp(at index: Int?) {
//            isClicked = false
//            isEntered = isFocus(at: index)
//            if isEntered {
//                if let action = interactiveEventActions[.mouseUpInside] {
//                    action?(range)
//                }
//            } else {
//                if let action = interactiveEventActions[.mouseUpOutside] {
//                    action?(range)
//                }
//            }
//            fixState()
//        }
//
//
//    }
//
//
//    var _isEnabled: Bool = true
//    open override var isEnabled: Bool {
//        get {
//            _isEnabled
//        }
//        set {
//            _isEnabled = newValue
//            items.forEach({
//                $0.isEnabled = _isEnabled
//                $0.fixState()
//            })
//            updateAttributesIfNeed()
//        }
//    }
//
//    open var isSelected: Bool = false {
//        didSet {
//            items.forEach({
//                $0.isSelected = isSelected
//                $0.fixState()
//            })
//            updateAttributesIfNeed()
//        }
//    }
//
//    /// 移动防抖
//    public var antiShakeEnable = true
//
//    /// 绘制文本边框
//    public var drawTextBorder = false
//
//    var items: [InteractiveItem] = []
//
//    public var mouseTrackingArea: NSTrackingArea!
//
//    private var moveEvent: NSEvent?
//
//    func configerTrackingArea() {
//        mouseTrackingArea = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
//        addTrackingArea(mouseTrackingArea)
//
//        if var mouseLocation = window?.mouseLocationOutsideOfEventStream {
//            mouseLocation = convert(mouseLocation, from: nil)
//            if bounds.contains(mouseLocation) {
//                mouseEntered(with: NSEvent())
//            } else {
//                mouseExited(with: NSEvent())
//            }
//        }
//    }
//
//    open override func resetCursorRects() {
//
//    }
//
//    func updateMouseEnterExitTrackingArea() {
//        if let mouseTrackingArea = mouseTrackingArea {
//            removeTrackingArea(mouseTrackingArea)
//        }
//        configerTrackingArea()
//
//
//    }
//
//    open override func mouseEntered(with event: NSEvent) {
//        mouseMoved(with: event)
//    }
//
//    open override func mouseExited(with event: NSEvent) {
//        mouseMoved(with: event)
//    }
//
//    open override func mouseDragged(with event: NSEvent) {
//        mouseMoved(with: event)
//    }
//
//    open override func updateTrackingAreas() {
//        super.updateTrackingAreas()
//        updateMouseEnterExitTrackingArea()
//    }
//
//    open override func mouseDown(with event: NSEvent) {
//        guard isEnabled else {
//            return
//        }
//        let index = locationStringIndex(in: event)
//        items.forEach({ $0.mouseDown(at: index) })
//        updateAttributesIfNeed()
//    }
//
//    open override func mouseUp(with event: NSEvent) {
//        guard isEnabled else {
//            return
//        }
//        let index = locationStringIndex(in: event)
//        items.forEach({ $0.mouseUp(at: index) })
//        updateAttributesIfNeed()
//    }
//
//    open override func mouseMoved(with event: NSEvent) {
//        if let moveEvent = moveEvent {
//            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(movedShake(with:)), object: moveEvent)
//        }
//        if let _ = locationStringIndex(in: event) {
//            moveEvent = event
//            self.perform(#selector(movedShake(with:)), with: event, afterDelay: antiShakeEnable ? 0.02 : 0)
//        } else {
//            moveEvent = nil
//            self.perform(#selector(movedShake(with:)), with: event, afterDelay: 0)
//        }
//    }
//
//    @objc func movedShake(with event: NSEvent) {
//        let index = locationStringIndex(in: event)
//        items.forEach({ $0.moved(at: index) })
//        updateAttributesIfNeed()
//    }
//
//
//    open override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//
//        if drawTextBorder {
//            let targetRect = CGRect(origin: .zero, size: CGSize(width: bounds.width - 4, height: bounds.height))
//            let context = NSGraphicsContext.current!.cgContext
//            context.textMatrix = CGAffineTransform.identity
//            context.translateBy(x: 0, y: bounds.height)
//            context.scaleBy(x: 1, y: -1)
//            let mutableAttributedString = attributedStringValue.mutableCopy() as! NSMutableAttributedString
//            loadAttachmentsSizeCallback(mutableAttributedString: mutableAttributedString)
//            let cfAttributedString = mutableAttributedString as CFMutableAttributedString
//            let ctFramesetter = CTFramesetterCreateWithAttributedString(cfAttributedString)
//            let path = CGPath(rect: targetRect, transform: nil)
//            let ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRange(location: 0, length: attributedStringValue.length), path, nil)
//            let lines = CTFrameGetLines(ctFrame) as! [CTLine]
//            var origins: [CGPoint] = .init(repeating: .zero, count: lines.count)
//            CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: 0), &origins)
//
//            for i in 0 ..< lines.count {
//                let line = lines[i]
//                let origin = origins[i]
//                let lineBounds = calculateLineBounds(line: line, origin: origin, lineIndex: i)
//
//                context.setLineWidth(1)
//                context.addRect(lineBounds)
//                context.setStrokeColor(NSColor.cyan.cgColor)
//                context.stroke(lineBounds)
//
//            }
//        }
//    }
//
//}
//
//private extension InteractiveLabel {
//
//    func interactiveItem(at range: NSRange) -> InteractiveItem {
//        if let first = items.first(where: { $0.range == range }) {
//            return first
//        }
//        let item = InteractiveItem(range: range, isEnabled: isEnabled, isSelected: isSelected)
//        items.append(item)
//        return item
//    }
//
//
//    func updateAttributesIfNeed() {
//        if items.contains(where: { $0.isNeedApply }) {
//            let attributedString = attributedStringValue.mutableCopy() as! NSMutableAttributedString
//            items.forEach({ $0.applyIfNeed(in: attributedString) })
//            attributedStringValue = attributedString
//        }
//    }
//
//    struct ImageRunStruct {
//        let ascent: CGFloat
//        let descent: CGFloat
//        let width: CGFloat
//    }
//
//    func locationStringIndex(in event: NSEvent) -> Int? {
//        var point = convert(event.locationInWindow, from: nil)
//        guard bounds.contains(point) else {
//            return nil
//        }
//        point.y = bounds.maxY - point.y
//        let targetRect = CGRect(origin: .zero, size: CGSize(width: bounds.width - 4, height: bounds.height))
//        let mutableAttributedString = attributedStringValue.mutableCopy() as! NSMutableAttributedString
//        loadAttachmentsSizeCallback(mutableAttributedString: mutableAttributedString)
//        let cfAttributedString = mutableAttributedString as CFMutableAttributedString
//        let ctFramesetter = CTFramesetterCreateWithAttributedString(cfAttributedString)
//        let path = CGPath(rect: targetRect, transform: nil)
//
//        let ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRange(location: 0, length: attributedStringValue.length), path, nil)
//        let lines = CTFrameGetLines(ctFrame) as! [CTLine]
//        var origins: [CGPoint] = .init(repeating: .zero, count: lines.count)
//        CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: 0), &origins)
//        for i in 0 ..< lines.count {
//            let line = lines[i]
//            let origin = origins[i]
//            let lineBounds = calculateLineBounds(line: line, origin: origin, lineIndex: i)
//            if let index = calculateStringIndexForPosition(line: line, lineBounds: lineBounds, point: point) {
//                return index
//            }
//        }
//        return nil
//    }
//
//    func loadAttachmentsSizeCallback(mutableAttributedString: NSMutableAttributedString) {
//        var attachmentsRangs: [NSRange] = []
//        for i in 0 ..< mutableAttributedString.length {
//            if mutableAttributedString.containsAttachments(in: NSRange(location: i, length: 1)) {
//                attachmentsRangs.append(NSRange(location: i, length: 1))
//            }
//        }
//
//        attachmentsRangs.forEach { range in
//            let att = mutableAttributedString.attributedSubstring(from: range)
//            let size = att.boundingRect(with: .zero)
//            let extentBuffer = UnsafeMutablePointer<ImageRunStruct>.allocate(capacity: 1)
//            extentBuffer.initialize(to: ImageRunStruct(ascent: size.height, descent: 0, width: size.width))
//            var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (pointer) in
//            }, getAscent: { (pointer) -> CGFloat in
//                let d = pointer.assumingMemoryBound(to: ImageRunStruct.self)
//                return d.pointee.ascent
//            }, getDescent: { (pointer) -> CGFloat in
//                let d = pointer.assumingMemoryBound(to: ImageRunStruct.self)
//                return d.pointee.descent
//            }, getWidth: { (pointer) -> CGFloat in
//                let d = pointer.assumingMemoryBound(to: ImageRunStruct.self)
//                return d.pointee.width
//            })
//            let delegate = CTRunDelegateCreate(&callbacks, extentBuffer)
//            let attrDictionaryDelegate = [(kCTRunDelegateAttributeName as NSAttributedString.Key): (delegate as Any)]
//            mutableAttributedString.setAttributes(attrDictionaryDelegate, range: range)
//        }
//    }
//
//    func calculateLineBounds(line: CTLine, origin: CGPoint, lineIndex i: Int) -> CGRect {
//        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
//
//        var imageWidths: [CGFloat] = []
//        var lineBottom: CGFloat = 0
//        for j in 0 ..< runs.count {
//            let run = runs[j]
//            let attributes = CTRunGetAttributes(run)
//            if let runDelegate = (attributes as Dictionary)[kCTRunDelegateAttributeName] {
//                let res = CTRunDelegateGetRefCon(runDelegate as! CTRunDelegate)
//                let callBack = res.assumingMemoryBound(to: ImageRunStruct.self).pointee
//                let imageSize = CGSize(width: callBack.width, height: callBack.ascent)
//                imageWidths.append(imageSize.width)
//            } else {
//                imageWidths.append(0)
//            }
//            let runBounds = CTRunGetImageBounds(run, nil, CFRange(location: 0, length: 0))
//            lineBottom = max(abs(runBounds.origin.y), lineBottom)
//        }
//
//        var imageOffset: CGFloat = 0
//        if imageWidths.contains(0) {
//            for j in 0 ..< imageWidths.count {
//                if imageWidths[j] == 0 {
//                    break
//                } else {
//                    imageOffset += imageWidths[j]
//                }
//            }
//        } else {
//            imageOffset += imageWidths.first ?? 0
//        }
//
//        var lineAscent: CGFloat = 0
//        var lineDescent: CGFloat = 0
//        var lineLeading: CGFloat = 0
//
//        let lineWidth = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading)
//        let lineHeight = lineAscent + lineLeading + lineBottom
//
//        var lineBounds = CTLineGetImageBounds(line, nil)
//        lineBounds.origin.x += origin.x - imageOffset
//        lineBounds.origin.y += origin.y  - CGFloat(1 * i)
//
//        lineBounds.origin.x = lineBounds.origin.x
//        lineBounds.origin.y = lineBounds.origin.y
//        lineBounds.size.width = lineWidth
//        lineBounds.size.height = lineHeight
//
//        return lineBounds
//    }
//
//    func calculateStringIndexForPosition(line: CTLine, lineBounds: CGRect, point: CGPoint) -> Int? {
//        if lineBounds.contains(point) {
//            let linePoint = CGPoint(x: point.x - lineBounds.origin.x, y: point.y - lineBounds.origin.y)
//            let lineStringRange = CTLineGetStringRange(line)
//            var firstLargeIndex = -1
//            for index in lineStringRange.location ..< lineStringRange.length + lineStringRange.location {
//                var offset: CGFloat = 0
//                CTLineGetOffsetForStringIndex(line, index, &offset)
//                if offset > linePoint.x {
//                    firstLargeIndex = index
//                    break
//                }
//            }
//            if firstLargeIndex == -1 {
//                firstLargeIndex = lineStringRange.length + lineStringRange.location
//            }
//            return firstLargeIndex - 1
//        }
//        return nil
//    }
//
//}
