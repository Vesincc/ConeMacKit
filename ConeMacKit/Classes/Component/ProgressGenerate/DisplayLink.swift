//
//  DisplayLink.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import Foundation
#if os(macOS)
import AppKit

typealias CADisplayLink = DisplayLink

/// Analog to the CADisplayLink in iOS.
class DisplayLink: NSObject {
    
    // This is the value of CADisplayLink.
    private static let duration = 0.016666667
    private static let frameInterval = 1
    private static let timestamp = 0.0 // 该值随时会变，就取个开始值吧!
    
    private let target: Any
    private let selector: Selector
    private let selParameterNumbers: Int
    private let timer: CVDisplayLink?
    private var source: DispatchSourceUserDataAdd?
    private var timeStampRef: CVTimeStamp = CVTimeStamp()
    
    /// Use this callback when the Selector parameter exceeds 1.
    var callback: Optional<(_ displayLink: DisplayLink) -> ()> = nil
    
    /// The refresh rate of 60HZ is 60 times per second, each refresh takes 1/60 of a second about 16.7 milliseconds.
    var duration: CFTimeInterval {
        guard let timer = timer else { return DisplayLink.duration }
        CVDisplayLinkGetCurrentTime(timer, &timeStampRef)
        return CFTimeInterval(timeStampRef.videoRefreshPeriod) / CFTimeInterval(timeStampRef.videoTimeScale)
    }
    
    /// Returns the time between each frame, that is, the time interval between each screen refresh.
    var timestamp: CFTimeInterval {
        guard let timer = timer else { return DisplayLink.timestamp }
        CVDisplayLinkGetCurrentTime(timer, &timeStampRef)
        return CFTimeInterval(timeStampRef.videoTime) / CFTimeInterval(timeStampRef.videoTimeScale)
    }
    
    /// Sets how many frames between calls to the selector method, defult 1
    var frameInterval: Int {
        guard let timer = timer else { return DisplayLink.frameInterval }
        CVDisplayLinkGetCurrentTime(timer, &timeStampRef)
        return Int(timeStampRef.rateScalar)
    }
    
    init(target: Any, selector sel: Selector) {
        self.target = target
        self.selector = sel
        self.selParameterNumbers = DisplayLink.selectorParameterNumbers(sel)
        var timerRef: CVDisplayLink? = nil
        CVDisplayLinkCreateWithActiveCGDisplays(&timerRef)
        self.timer = timerRef
    }
    
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode) {
        guard let timer = timer else { return }
        let queue: DispatchQueue = runloop == RunLoop.main ? .main : .global()
        self.source = DispatchSource.makeUserDataAddSource(queue: queue)
        var successLink = CVDisplayLinkSetOutputCallback(timer, { (_, _, _, _, _, pointer) -> CVReturn in
            if let sourceUnsafeRaw = pointer {
                let sourceUnmanaged = Unmanaged<DispatchSourceUserDataAdd>.fromOpaque(sourceUnsafeRaw)
                sourceUnmanaged.takeUnretainedValue().add(data: 1)
            }
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(source!).toOpaque())
        guard successLink == kCVReturnSuccess else {
            return
        }
        successLink = CVDisplayLinkSetCurrentCGDisplay(timer, CGMainDisplayID())
        guard successLink == kCVReturnSuccess else {
            return
        }
        // Timer setup
        source!.setEventHandler(handler: { [weak self] in
            guard let `self` = self, let target = self.target as? NSObject else {
                return
            }
            switch self.selParameterNumbers {
            case 0 where self.selector.description.isEmpty == false:
                target.perform(self.selector)
            case 1:
                target.perform(self.selector, with: self)
            default:
                self.callback?(self)
                break
            }
        })
    }
    
    var isPaused: Bool = true {
        didSet {
            isPaused ? cancel() : start()
        }
    }
    
    func invalidate() {
        cancel()
    }
    
    deinit {
        if running() {
            cancel()
        }
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
    
    /// Starts the timer.
    private func start() {
        guard !running(), let timer = timer else { return }
        CVDisplayLinkStart(timer)
        source?.resume()
    }
    
    /// Cancels the timer, can be restarted aftewards.
    private func cancel() {
        guard running(), let timer = timer else { return }
        CVDisplayLinkStop(timer)
        source?.cancel()
    }
    
    private func running() -> Bool {
        guard let timer = timer else { return false }
        return CVDisplayLinkIsRunning(timer)
    }
}
#endif
