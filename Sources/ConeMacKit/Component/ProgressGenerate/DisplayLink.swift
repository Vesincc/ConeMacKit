//
//  DisplayLink.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import Foundation
#if os(macOS)
import AppKit

public typealias CADisplayLink = DisplayLink

/// Analog to the CADisplayLink in iOS.
public class DisplayLink: NSObject {
    
    var fps: CGFloat = 60 {
        didSet {
            preferDuration = 1 / fps
        }
    }
    
    // This is the value of CADisplayLink.
    private var preferDuration = 0.016666667
    private let preferFrameInterval = 1
    private let preferTimestamp = 0.0 // 该值随时会变，就取个开始值吧!
    
    private weak var target: AnyObject?
    private let selector: Selector
    private let selParameterNumbers: Int
    private let timer: CVDisplayLink?
    private var source: DispatchSourceUserDataAdd?
    private var timeStampRef: CVTimeStamp = CVTimeStamp()
    private var sourceResumedOnce = false
    
    /// Use this callback when the Selector parameter exceeds 1.
    var callback: Optional<(_ displayLink: DisplayLink) -> ()> = nil
    
    /// The refresh rate of 60HZ is 60 times per second, each refresh takes 1/60 of a second about 16.7 milliseconds.
    public var duration: CFTimeInterval {
        guard let timer = timer else { return preferDuration }
        CVDisplayLinkGetCurrentTime(timer, &timeStampRef)
        return CFTimeInterval(timeStampRef.videoRefreshPeriod) / CFTimeInterval(timeStampRef.videoTimeScale)
    }
    
    /// Returns the time between each frame, that is, the time interval between each screen refresh.
    public var timestamp: CFTimeInterval {
        guard let timer = timer else { return preferTimestamp }
        CVDisplayLinkGetCurrentTime(timer, &timeStampRef)
        return CFTimeInterval(timeStampRef.videoTime) / CFTimeInterval(timeStampRef.videoTimeScale)
    }
    
    /// Sets how many frames between calls to the selector method, defult 1
    public var frameInterval: Int {
        guard let timer = timer else { return preferFrameInterval }
        CVDisplayLinkGetCurrentTime(timer, &timeStampRef)
        return Int(timeStampRef.rateScalar)
    }
    
    public init(target: AnyObject, selector sel: Selector) {
        self.target = target
        self.selector = sel
        self.selParameterNumbers = DisplayLink.selectorParameterNumbers(sel)
        var timerRef: CVDisplayLink? = nil
        CVDisplayLinkCreateWithActiveCGDisplays(&timerRef)
        self.timer = timerRef
    }
    
    public func add(to runloop: RunLoop, forMode mode: RunLoop.Mode) {
        guard let timer = timer else { return }
        let queue: DispatchQueue = runloop == .main ? .main : .global()
        self.source = DispatchSource.makeUserDataAddSource(queue: queue)
        
        let successLink = CVDisplayLinkSetOutputCallback(timer, { (_, _, _, _, _, pointer) -> CVReturn in
            guard let sourceRaw = pointer else { return kCVReturnError }
            let source = Unmanaged<DispatchSourceUserDataAdd>.fromOpaque(sourceRaw).takeUnretainedValue()
            source.add(data: 1)
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(source!).toOpaque())
        
        guard successLink == kCVReturnSuccess,
              CVDisplayLinkSetCurrentCGDisplay(timer, CGMainDisplayID()) == kCVReturnSuccess else {
            return
        }
        
        source!.setEventHandler { [weak self] in
            guard let self = self, let target = self.target as? NSObject else { return }
            switch self.selParameterNumbers {
            case 0 where !self.selector.description.isEmpty:
                target.perform(self.selector)
            case 1:
                target.perform(self.selector, with: self)
            default:
                self.callback?(self)
            }
        }
        
        if !sourceResumedOnce {
            source!.resume()
            sourceResumedOnce = true
        }
    }
    
    public var isPaused: Bool = true {
        didSet {
            isPaused ? stop() : start()
        }
    }
    
    public func invalidate() {
        stop()
        source?.cancel()
    }
    
    deinit {
        if running() {
            stop()
        }
    }
    
    private func start() {
        guard !running(), let timer = timer else { return }
        CVDisplayLinkStart(timer)
    }
    
    private func stop() {
        guard running(), let timer = timer else { return }
        CVDisplayLinkStop(timer)
    }
    
    private func running() -> Bool {
        guard let timer = timer else { return false }
        return CVDisplayLinkIsRunning(timer)
    }
}

extension DisplayLink {
    /// Get the number of parameters contained in the Selector method.
    private class func selectorParameterNumbers(_ sel: Selector) -> Int {
        var number: Int = 0
        for x in sel.description where x == ":" {
            number += 1
        }
        return number
    }
}
#endif
