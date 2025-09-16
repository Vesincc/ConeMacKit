//
//  File.swift
//  ConeMacKit
//
//  Created by HanQi on 2025/6/13.
//

import AppKit
 
public class WindowButtonGroupBar: NSStackView {
    
    public override var appearance: NSAppearance? {
        didSet {
            buttons.forEach({
                $0?.appearance = appearance
            })
        }
    }
    
    public var isHovered = false {
        didSet {
            updateButtonsState()
        }
    }
    
    public var types: [NSWindow.ButtonType] = [.closeButton]
    
    public var buttons: [NSButton?] = []
    
    public init(types: [NSWindow.ButtonType]) {
        super.init(frame: .zero)
        self.types = types
        configerViews()
    }
    
    public var _trackingArea: NSTrackingArea?
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    
    public func configerViews() {
        buttons = types.map({
            let button = NSWindow.standardWindowButton($0, for: .closable)
            if let button = button {
                addArrangedSubview(button)
                button.addTrackingArea(NSTrackingArea(rect: button.bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self, userInfo: nil))
            }
            return button
        })
        spacing = 6
        configerTrackingArea()
         
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func configerTrackingArea() {
        if let _trackingArea = _trackingArea {
            removeTrackingArea(_trackingArea)
            self._trackingArea = nil
        }
        let trackArea = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(trackArea)
        _trackingArea = trackArea
    }
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        configerTrackingArea()
    }
    
    @objc public func _mouseInGroup(_ button: NSButton) -> Bool {
        return isHovered
    }
    
    public override func mouseEntered(with event: NSEvent) {
        isHovered = true
    }
    
    public override func mouseExited(with event: NSEvent) {
        isHovered = false
    }
    
    public func updateButtonsState() {
        buttons.forEach({
            $0?.needsDisplay = true
            $0?.needsLayout = true
        })
    }
    
    public func button(for type: NSWindow.ButtonType) -> NSButton? {
        guard let index = types.firstIndex(of: type),
              let button = buttons[safe: index] else {
            return nil
        }
        return button
    }
    
}
