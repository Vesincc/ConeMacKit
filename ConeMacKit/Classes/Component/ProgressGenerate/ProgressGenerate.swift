//
//  ProgressGenerate.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/3/14.
//

import Foundation
import QuartzCore

public protocol ProgressGenerateProtocol {
    func progressForm(_ startValue: CGFloat, to endValue: CGFloat, with duration: TimeInterval)
    func progress(to endValue: CGFloat, with duration: TimeInterval)
    
    func stopProgress()
}

public class ProgressGenerate: NSObject {
    
    public var fps: CGFloat
    
    public init(fps: CGFloat = 60) {
        self.fps = fps
    }
    
    public var updateBlock: ((CGFloat) -> Void)?
    public var completionBlock: (() -> Void)?
    
    private var fromValue: CGFloat = 0
    private var toValue: CGFloat = 1
    private var currentDuration: TimeInterval = 0
    private var totalDuration: TimeInterval = 1
    private var lastUpdate: TimeInterval = 0
    
    private var timer: CADisplayLink?
    
    public var isProgressing: Bool {
        timer != nil
    }
    
    public var progress: CGFloat {
        guard totalDuration != 0 else { return 1 }
        return CGFloat(currentDuration / totalDuration)
    }
    
    var currentValue: CGFloat {
        if currentDuration == 0 {
            return 0
        } else if currentDuration >= totalDuration {
            return toValue
        }
        return fromValue + progress * (toValue - fromValue)
    }
    
    // CADisplayLink callback
    @objc public func updateValue(_ timer: Timer) {
        let now = CACurrentMediaTime()
        currentDuration += now - lastUpdate
        lastUpdate = now
        
        if currentDuration >= totalDuration {
            invalidate()
            currentDuration = totalDuration
        }
        
        updateBlock?(currentValue)
        
        if currentDuration == totalDuration {
            runCompletionBlock()
        }
    }
    
    private func runCompletionBlock() {
        completionBlock?()
    }
    
    //set init values
    public func reset() {
        invalidate()
        fromValue = 0
        toValue = 1
        currentDuration = 0
        lastUpdate = 0
        totalDuration = 1
    }
    
    public func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

extension ProgressGenerate: ProgressGenerateProtocol {
    public func progressForm(_ startValue: CGFloat, to endValue: CGFloat, with duration: TimeInterval) {
        fromValue = startValue
        toValue = endValue
        
        // remove any (possible) old timers
        invalidate()
        
        if duration == 0.0 {
            // No animation
            updateBlock?(endValue)
            runCompletionBlock()
            return
        }
        
        currentDuration = 0
        totalDuration = duration
        lastUpdate = CACurrentMediaTime()
        
        let timer = CADisplayLink(target: self, selector: #selector(updateValue(_:)))
        timer.fps = self.fps
        timer.add(to: .main, forMode: .default)
        timer.isPaused = false
        self.timer = timer
    }
    
    public func progress(to endValue: CGFloat, with duration: TimeInterval) {
        progressForm(currentValue, to: endValue, with: duration)
    }
    
    public func stopProgress() {
        invalidate()
        updateBlock?(currentValue)
    }
}

public protocol ProgressGenerateHelper: AnyObject, ProgressGenerateProtocol {
    var progresser: ProgressGenerate { get }
}

public extension ProgressGenerateHelper {
    func setUpdateBlock(_ block: ((_ value: CGFloat, _ sender: Self) -> Void)?) {
        if let block = block {
            progresser.updateBlock = { [weak self] value in
                guard let self = self else { return }
                block(value, self)
            }
        } else {
            progresser.updateBlock = nil
        }
    }
    
    func setCompltionBlock(_ completion: ((_ sender: Self) -> Void)?) {
        if let completion = completion {
            progresser.completionBlock = { [weak self] in
                guard let self = self else { return }
                completion(self)
            }
        } else {
            progresser.completionBlock = nil
        }
    }
    
    func progressForm(_ startValue: CGFloat, to endValue: CGFloat, with duration: TimeInterval) {
        progresser.progressForm(startValue, to: endValue, with: duration)
    }
    
    func progress(to endValue: CGFloat, with duration: TimeInterval) {
        progresser.progress(to: endValue, with: duration)
    }
    
    func stopProgress() {
        progresser.stopProgress()
    }
}
