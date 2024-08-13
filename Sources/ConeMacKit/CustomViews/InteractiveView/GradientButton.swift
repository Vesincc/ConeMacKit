//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/3.
//

import Foundation
import AppKit

open class GradientButton: InteractiveButton, InteractiveGradientButtonProtocol {
    
    public var direction: Interactive.GradientDirection = .horizontal
    
    public override var backgroundColorEnable: Bool {
        false
    }
    
    public var interactiveColors: [Interactive.State : [NSColor]] = [:]
    
    public var interactivePoints: [Interactive.State : (start: CGPoint, end: CGPoint)] = [:]
    
    public var interactiveLocations: [Interactive.State : [NSNumber]] = [:]
    
    open override func makeBackingLayer() -> CALayer {
        let backingLayer = super.makeBackingLayer()
        let gradientLayer = CAGradientLayer()
        gradientLayer.contentsScale = backingLayer.contentsScale
        gradientLayer.needsDisplayOnBoundsChange = true
        return gradientLayer
    }
    
    var gradientLayer: CAGradientLayer? {
        layer as? CAGradientLayer
    }
    
    public override func interactiveStateDidChanged(lastState: Interactive.State) {
        super.interactiveStateDidChanged(lastState: lastState)
        let priority = statePriority(for: interactiveState)
        let info = direction.info
        let colors = adapterValue(in: interactiveColors, for: priority)
        let points = adapterValue(in: interactivePoints, for: priority) ?? info.points
        let locations = adapterValue(in: interactiveLocations, for: priority) ?? info.locations
        
        guard let colors = colors else {
            return
        }
        gradientLayer?.colors = colors.map({ $0.cgColor })
        gradientLayer?.startPoint = points.start
        gradientLayer?.endPoint = points.end
        gradientLayer?.locations = locations
        
    }
    
}
